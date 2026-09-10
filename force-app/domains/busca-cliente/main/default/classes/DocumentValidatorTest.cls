/**
 * @description Testes de DocumentValidator: CPF/DV, CNPJ/DV, BACEN, protocolo,
 * nao-cliente, normalizacao e mascara (Cen 1-5, EL-01/02).
 */
@IsTest
private class DocumentValidatorTest {

    @IsTest
    static void cpfValido() {
        DocumentValidator.ValidationResult r = DocumentValidator.validate('529.982.247-25', 'PF');
        System.assertEquals(true, r.valid, 'CPF valido deve passar');
        System.assertEquals('CPF', r.docType);
        System.assertEquals('52998224725', r.normalized);
    }

    @IsTest
    static void cpfDigitoInvalidoNaoDisparaBusca() {
        DocumentValidator.ValidationResult r = DocumentValidator.validate('12345678999', 'PF');
        System.assertEquals(false, r.valid, 'DV invalido bloqueia antes de qualquer callout');
    }

    @IsTest
    static void cpfSequenciaRepetidaInvalida() {
        System.assertEquals(false, DocumentValidator.isValidCpf('11111111111'));
    }

    @IsTest
    static void cnpjNumericoValido() {
        DocumentValidator.ValidationResult r = DocumentValidator.validate('11.444.777/0001-61', 'PJ');
        System.assertEquals(true, r.valid, 'CNPJ valido deve passar');
        System.assertEquals('CNPJ', r.docType);
    }

    @IsTest
    static void cnpjAlfaBacenValido() {
        DocumentValidator.ValidationResult r = DocumentValidator.validate('12ABC34501DE35', 'PJ');
        System.assertEquals(true, r.valid, 'CNPJ alfanumerico BACEN deve passar por formato');
        System.assertEquals('CNPJ_ALFANUM', r.docType);
    }

    @IsTest
    static void cnpjAlfaForaDoPadraoInvalido() {
        System.assertEquals(false, DocumentValidator.isValidCnpjAlfa('12ABC!4501DE35'));
        System.assertEquals(false, DocumentValidator.isValidCnpjAlfa('1234567890123'));
    }

    @IsTest
    static void protocoloMinimo5Chars() {
        System.assertEquals(false, DocumentValidator.validate('1234', 'PROTOCOLO').valid);
        System.assertEquals(true, DocumentValidator.validate('12345', 'PROTOCOLO').valid);
    }

    @IsTest
    static void naoClienteAceitaQualquerValor() {
        System.assertEquals(false, DocumentValidator.validate('', 'NAO_CLIENTE').valid);
        System.assertEquals(true, DocumentValidator.validate('X-999', 'NAO_CLIENTE').valid);
    }

    @IsTest
    static void normalizaEMascara() {
        System.assertEquals('52998224725', DocumentValidator.normalizeDoc('529.982.247-25'));
        System.assertEquals('529.982.247-25', DocumentValidator.mask('52998224725', 'CPF'));
        System.assertEquals(
            '12.ABC.345/01DE-35', DocumentValidator.mask('12ABC34501DE35', 'CNPJ_ALFANUM'));
    }

    @IsTest
    static void modoDesconhecidoRejeitado() {
        System.assertEquals(false, DocumentValidator.validate('123', 'XPTO').valid);
    }
}
