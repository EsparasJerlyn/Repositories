/**
 * @description Interface for WebCarts DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
public interface IWebCartsDAO extends DmlInterface {

    List<WebCart> getWebCartByUserId(
        Set<Id> userId,
        AccessLevel accessLevel
    );
}
