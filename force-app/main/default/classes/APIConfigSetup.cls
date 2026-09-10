/**
 * @description Cria a Lookup Table API_Config (Business Rules Engine)
 *              100% via codigo: matrix + versao + colunas + linhas BCP.
 *              Idempotente: pode rodar quantas vezes quiser.
 *              Uso: sf apex run -f scripts/setup-api-config.apex
 *              ou Developer Console: APIConfigSetup.setup();
 */
public with sharing class APIConfigSetup {

    private static final String MATRIX_LABEL = 'API Config';
    private static final String MATRIX_UNIQUE_NAME = 'API_Config';
    private static final String VERSION_NAME = 'v1';

    private class ColumnDef {
        String name;
        String type;
        Integer seq;
        ColumnDef(String name, String type, Integer seq) {
            this.name = name;
            this.type = type;
            this.seq = seq;
        }
    }

    private class RowDef {
        String apiName;
        String environment;
        String operation;
        String namedCredential;
        String endpoint;
        RowDef(String apiName, String environment, String operation, String namedCredential, String endpoint) {
            this.apiName = apiName;
            this.environment = environment;
            this.operation = operation;
            this.namedCredential = namedCredential;
            this.endpoint = endpoint;
        }
    }

    public static void setup() {
        Id matrixId = ensureMatrix();
        ensureColumns(matrixId);
        Id versionId = ensureVersion(matrixId);
        ensureRows(versionId);
        ensureVersionEnabled(versionId);
        APIConfigDAO.clearCache();
    }

    private static Id ensureMatrix() {
        List<CalculationMatrix> existing = [
            SELECT Id FROM CalculationMatrix WHERE UniqueName = :MATRIX_UNIQUE_NAME LIMIT 1
        ];
        if (!existing.isEmpty()) {
            return existing[0].Id;
        }
        CalculationMatrix matrix = new CalculationMatrix(
            Name = MATRIX_LABEL,
            UniqueName = MATRIX_UNIQUE_NAME,
            Description = 'Configuracao de integracoes por API + ambiente + operacao (arquitetura de referencia).'
        );
        insert matrix;
        return matrix.Id;
    }

    private static Id ensureVersion(Id matrixId) {
        List<CalculationMatrixVersion> all = [
            SELECT Id FROM CalculationMatrixVersion
            WHERE CalculationMatrixId = :matrixId
            ORDER BY VersionNumber DESC LIMIT 1
        ];
        if (!all.isEmpty()) {
            return all[0].Id;
        }
        CalculationMatrixVersion version = new CalculationMatrixVersion(
            Name = VERSION_NAME,
            CalculationMatrixId = matrixId,
            IsEnabled = false,
            VersionNumber = 1
        );
        insert version;
        return version.Id;
    }

    private static void ensureVersionEnabled(Id versionId) {
        CalculationMatrixVersion version = [
            SELECT Id, IsEnabled FROM CalculationMatrixVersion WHERE Id = :versionId LIMIT 1
        ];
        if (!version.IsEnabled) {
            version.IsEnabled = true;
            update version;
        }
    }

    private static void ensureColumns(Id matrixId) {
        List<ColumnDef> defs = new List<ColumnDef>{
            new ColumnDef('API_Name',        'Input',  1),
            new ColumnDef('Environment',     'Input',  2),
            new ColumnDef('Operation',       'Input',  3),
            new ColumnDef('NamedCredential', 'Output', 4),
            new ColumnDef('Endpoint',        'Output', 5),
            new ColumnDef('Method',          'Output', 6),
            new ColumnDef('Timeout',         'Output', 7),
            new ColumnDef('RetryEnabled',    'Output', 8),
            new ColumnDef('RetryCount',      'Output', 9),
            new ColumnDef('LogEnabled',      'Output', 10)
        };

        Map<String, CalculationMatrixColumn> existing = new Map<String, CalculationMatrixColumn>();
        for (CalculationMatrixColumn col : [
            SELECT ApiName FROM CalculationMatrixColumn WHERE CalculationMatrixId = :matrixId
        ]) {
            existing.put(col.ApiName, col);
        }

        List<CalculationMatrixColumn> toInsert = new List<CalculationMatrixColumn>();
        for (ColumnDef def : defs) {
            if (existing.containsKey(def.name)) {
                continue;
            }
            toInsert.add(
                new CalculationMatrixColumn(
                    CalculationMatrixId = matrixId,
                    Name = def.name,
                    ApiName = def.name,
                    ColumnType = def.type,
                    DataType = 'Text',
                    DisplaySequence = def.seq
                )
            );
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }

    private static void ensureRows(Id versionId) {
        List<RowDef> defs = new List<RowDef>{
            new RowDef(
                'BCP_DadosCliente',
                'Homologacao',
                'getDadosCliente',
                'BCP_Homologacao',
                '/conta/bl/atendimento/v1/accounts/dados-cliente'
            ),
            new RowDef(
                'BCP_DadosCliente',
                'Producao',
                'getDadosCliente',
                'BCP_Producao',
                '/conta/bl/atendimento/v1/accounts/dados-cliente'
            )
        };

        Set<String> existingKeys = new Set<String>();
        for (CalculationMatrixRow row : [
            SELECT InputData FROM CalculationMatrixRow WHERE CalculationMatrixVersionId = :versionId LIMIT 1000
        ]) {
            String key = keyOf(row.InputData);
            if (key != null) {
                existingKeys.add(key);
            }
        }

        List<CalculationMatrixRow> toInsert = new List<CalculationMatrixRow>();
        for (RowDef def : defs) {
            String key = def.apiName + '|' + def.environment + '|' + def.operation;
            if (existingKeys.contains(key)) {
                continue;
            }
            Map<String, Object> input = new Map<String, Object>{
                'API_Name'    => def.apiName,
                'Environment' => def.environment,
                'Operation'   => def.operation
            };
            Map<String, Object> output = new Map<String, Object>{
                'NamedCredential' => def.namedCredential,
                'Endpoint'        => def.endpoint,
                'Method'          => 'GET',
                'Timeout'         => '30000',
                'RetryEnabled'    => 'true',
                'RetryCount'      => '1',
                'LogEnabled'      => 'true'
            };
            toInsert.add(
                new CalculationMatrixRow(
                    Name = def.apiName + '_' + def.environment + '_' + def.operation,
                    CalculationMatrixVersionId = versionId,
                    InputData = JSON.serialize(input),
                    OutputData = JSON.serialize(output)
                )
            );
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }

    private static String keyOf(String inputData) {
        if (String.isBlank(inputData)) {
            return null;
        }
        try {
            Map<String, Object> input = (Map<String, Object>) JSON.deserializeUntyped(inputData);
            if (!input.containsKey('API_Name') || !input.containsKey('Environment') || !input.containsKey('Operation')) {
                return null;
            }
            return String.valueOf(input.get('API_Name')) + '|' +
                   String.valueOf(input.get('Environment')) + '|' +
                   String.valueOf(input.get('Operation'));
        } catch (Exception e) {
            return null;
        }
    }
}