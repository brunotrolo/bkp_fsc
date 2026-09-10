/**
 * @description Testes da UserInformation (nome, saudacao por horario, expiracao trial).
 */
@isTest
private class UserInformationTest {

    @isTest
    static void shouldReturnFirstName_WhenAsked() {
        // When
        Test.startTest();
        String result = UserInformation.getName();
        Test.stopTest();

        // Then
        Assert.areEqual(UserInfo.getFirstName(), result, 'Deve retornar o first name do usuario corrente.');
    }

    @isTest
    static void shouldReturnGreetingMatchingCurrentHour_WhenAsked() {
        // Given
        Integer hour = Datetime.now().hour();
        String expectedGreeting = hour < 12 ? 'Morning' : (hour < 17 ? 'Afternoon' : 'Evening');

        // When
        Test.startTest();
        String result = UserInformation.getTiming();
        Test.stopTest();

        // Then
        Assert.areEqual(expectedGreeting, result, 'Saudacao deve bater com a hora corrente: ' + hour);
    }

    @isTest
    static void shouldReturnDaysUntilTrialExpiration_WhenAsked() {
        // Given
        Organization org = [SELECT TrialExpirationDate FROM Organization LIMIT 1];
        Integer expected = Date.today().daysBetween(Date.valueOf(org.TrialExpirationDate));

        // When
        Test.startTest();
        Integer result = UserInformation.getExpiryDays();
        Test.stopTest();

        // Then
        Assert.areEqual(expected, result, 'Dias devem bater com TrialExpirationDate da org.');
    }
}
