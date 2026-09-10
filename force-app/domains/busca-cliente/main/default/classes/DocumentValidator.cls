/**
 * @description Validacao local de formato e digito verificador antes de qualquer
 * consulta externa (P1, RN-01 a RN-03, EL-01/02). Espelha a logica do prototipo
 * em prototype/data/buscaCliente/buscaCliente.js. CNPJ alfanumerico BACEN valida
 * apenas formato (12 alfanumericos + 2 digitos); DV alfanumerico e premissa 07.
 */
public with sharing class DocumentValidator {

    /** Modos de busca da entrada (P1). */
    public static final String MODO_PF = 'PF';
    public static final String MODO_PJ = 'PJ';
    public static final String MODO_PROTOCOLO = 'PROTOCOLO';
    public static final String MODO_NAO_CLIENTE = 'NAO_CLIENTE';

    /** Resultado da validacao: valido, tipo e mensagem de orientacao. */
    public class ValidationResult {
        public Boolean valid;
        public String docType;
        public String normalized;
        public String message;
        public ValidationResult(Boolean valid, String docType, String normalized, String message) {
            this.valid = valid;
            this.docType = docType;
            this.normalized = normalized;
            this.message = message;
        }
    }

    /** Normaliza: maiusculas, sem pontuacao. A mascara e so apresentacao. */
    public static String normalizeDoc(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.toUpperCase().replaceAll('[^A-Z0-9]', '');
    }

    /** Valida conforme o modo e retorna o resultado com orientacao. */
    public static ValidationResult validate(String value, String modo) {
        String normalized = normalizeDoc(value);
        String mode = String.isBlank(modo) ? MODO_PF : modo.toUpperCase();
        if (mode == MODO_PF) {
            if (!isValidCpf(normalized)) {
                return new ValidationResult(false, 'CPF', normalized, 'CPF em formato invalido. Confira os 11 digitos.');
            }
            return new ValidationResult(true, 'CPF', normalized, 'Formato valido.');
        }
        if (mode == MODO_PJ) {
            if (isValidCnpj(normalized)) {
                return new ValidationResult(true, 'CNPJ', normalized, 'Formato valido.');
            }
            if (isValidCnpjAlfa(normalized)) {
                return new ValidationResult(true, 'CNPJ_ALFANUM', normalized, 'Formato valido.');
            }
            return new ValidationResult(false, 'CNPJ', normalized, 'CNPJ em formato invalido. Confira os 14 digitos ou o padrao BACEN.');
        }
        if (mode == MODO_PROTOCOLO) {
            if (String.isBlank(normalized) || normalized.length() < 5) {
                return new ValidationResult(false, 'PROTOCOLO', normalized, 'Protocolo deve ter ao menos 5 caracteres.');
            }
            return new ValidationResult(true, 'PROTOCOLO', normalized, 'Formato valido.');
        }
        if (mode == MODO_NAO_CLIENTE) {
            if (String.isBlank(normalized)) {
                return new ValidationResult(false, 'NAO_CLIENTE', normalized, 'Informe o documento para iniciar o atendimento.');
            }
            return new ValidationResult(true, 'NAO_CLIENTE', normalized, 'Formato valido.');
        }
        return new ValidationResult(false, 'DESCONHECIDO', normalized, 'Modo de busca desconhecido.');
    }

    /** CPF: 11 digitos + DV mod11; rejeita sequencias repetidas. */
    public static Boolean isValidCpf(String normalized) {
        if (String.isBlank(normalized) || !Pattern.matches('[0-9]{11}', normalized)) {
            return false;
        }
        if (isRepeatedSequence(normalized)) {
            return false;
        }
        List<Integer> digits = toDigits(normalized);
        Integer dv1 = mod11Check(digits, 9, 10);
        Integer dv2 = mod11Check(digits, 10, 11);
        return dv1 == digits[9] && dv2 == digits[10];
    }

    /** CNPJ numerico: 14 digitos + DV mod11 com pesos 5..2/6..2. */
    public static Boolean isValidCnpj(String normalized) {
        if (String.isBlank(normalized) || !Pattern.matches('[0-9]{14}', normalized)) {
            return false;
        }
        if (isRepeatedSequence(normalized)) {
            return false;
        }
        List<Integer> digits = toDigits(normalized);
        Integer dv1 = cnpjCheck(digits, 12);
        Integer dv2 = cnpjCheck(digits, 13);
        return dv1 == digits[12] && dv2 == digits[13];
    }

    /** CNPJ alfanumerico BACEN: 12 posicoes alfanumericas + 2 digitos. Sem DV (premissa 07). */
    public static Boolean isValidCnpjAlfa(String normalized) {
        if (String.isBlank(normalized) || !Pattern.matches('[A-Z0-9]{12}[0-9]{2}', normalized)) {
            return false;
        }
        // Apenas formato: garante que ha ao menos uma letra (senao seria CNPJ numerico).
        return Pattern.matches('.*[A-Z].*', normalized.substring(0, 12));
    }

    /** Aplica mascara visual sem alterar o valor logico (so PF/PJ). */
    public static String mask(String normalized, String docType) {
        if (String.isBlank(normalized)) {
            return '';
        }
        if (docType == 'CPF' && normalized.length() == 11) {
            return normalized.substring(0, 3) + '.' + normalized.substring(3, 6) + '.'
                + normalized.substring(6, 9) + '-' + normalized.substring(9, 11);
        }
        if ((docType == 'CNPJ' || docType == 'CNPJ_ALFANUM') && normalized.length() == 14) {
            return normalized.substring(0, 2) + '.' + normalized.substring(2, 5) + '.'
                + normalized.substring(5, 8) + '/' + normalized.substring(8, 12) + '-'
                + normalized.substring(12, 14);
        }
        return normalized;
    }

    private static Boolean isRepeatedSequence(String value) {
        String first = value.substring(0, 1);
        for (Integer i = 1; i < value.length(); i++) {
            if (value.substring(i, i + 1) != first) {
                return false;
            }
        }
        return true;
    }

    private static List<Integer> toDigits(String value) {
        List<Integer> digits = new List<Integer>();
        for (Integer i = 0; i < value.length(); i++) {
            digits.add(Integer.valueOf(value.substring(i, i + 1)));
        }
        return digits;
    }

    private static Integer mod11Check(List<Integer> digits, Integer length, Integer weightStart) {
        Integer sum = 0;
        for (Integer i = 0; i < length; i++) {
            sum += digits[i] * (weightStart - i);
        }
        Integer remainder = Math.mod(sum, 11);
        return remainder < 2 ? 0 : 11 - remainder;
    }

    private static Integer cnpjCheck(List<Integer> digits, Integer length) {
        Integer sum = 0;
        Integer weight = length == 12 ? 5 : 6;
        for (Integer i = 0; i < length; i++) {
            sum += digits[i] * weight;
            weight = weight == 2 ? 9 : weight - 1;
        }
        Integer remainder = Math.mod(sum, 11);
        return remainder < 2 ? 0 : 11 - remainder;
    }
}
