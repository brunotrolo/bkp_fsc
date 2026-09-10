/**
 * @description Fabrica compartilhada dos testes da jornada busca-cliente/001.
 * Cria usuario operador com o PS_BuscaCliente_Agente atribuido para que os
 * testes cubram o mesmo enforcement de CRUD/FLS da producao (WITH USER_MODE).
 * Usa o perfil do usuario em execucao para garantir licenca compativel.
 */
@IsTest
public class BuscaClienteTestFactory {

    /** Cria operador com o permission set da jornada atribuido. */
    public static User novoAgente() {
        String uniq = String.valueOf(Datetime.now().getTime())
            + String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User agente = new User(
            Alias = 'ag' + uniq.right(6),
            Email = 'agente.busca.cliente@teste.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AgenteBusca',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Sao_Paulo',
            Username = 'agente.' + uniq + '@busca.cliente.teste'
        );
        insert agente;
        Id psId = [SELECT Id FROM PermissionSet WHERE Name = 'PS_BuscaCliente_Agente' LIMIT 1].Id;
        insert new PermissionSetAssignment(AssigneeId = agente.Id, PermissionSetId = psId);
        return agente;
    }
}
