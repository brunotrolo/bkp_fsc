/**
 * @description Testes da APIException (fabricas, getters, apiMessage).
 */
@isTest
private class APIExceptionTest {

    @isTest
    static void shouldPreserveCodeAndMessage_WhenCreateWithTwoArgs() {
        // When
        Test.startTest();
        APIException e = APIException.create('CONFIG_NOT_FOUND', 'Lookup ausente.');
        Test.stopTest();

        // Then
        Assert.areEqual('CONFIG_NOT_FOUND', e.getErrorCode(), 'Error code deve ser preservado.');
        Assert.areEqual('Lookup ausente.', e.getMessage(), 'Mensagem deve ser preservada.');
        Assert.isNull(e.getHttpStatusCode(), 'Sem status no create de 2 args.');
    }

    @isTest
    static void shouldPreserveHttpStatus_WhenCreateWithThreeArgs() {
        // When
        Test.startTest();
        APIException e = APIException.create('BCP_ERROR', 'Falha', 500);
        Test.stopTest();

        // Then
        Assert.areEqual('BCP_ERROR', e.getErrorCode(), 'Error code deve ser preservado.');
        Assert.areEqual(500, e.getHttpStatusCode(), 'Status HTTP deve ser preservado.');
    }

    @isTest
    static void shouldReturnNullApiMessage_WhenNeverSet() {
        // When
        Test.startTest();
        APIException e = APIException.create('X', 'Y');
        Test.stopTest();

        // Then
        Assert.isNull(e.getApiMessage(), 'apiMessage deve nascer nula.');
    }

    @isTest
    static void shouldRoundTripApiMessage_WhenSet() {
        // Given
        APIException e = APIException.create('X', 'Y');

        // When
        Test.startTest();
        e.setApiMessage('detalhe');
        Test.stopTest();

        // Then
        Assert.areEqual('detalhe', e.getApiMessage(), 'apiMessage deve fazer round-trip.');
    }
}
