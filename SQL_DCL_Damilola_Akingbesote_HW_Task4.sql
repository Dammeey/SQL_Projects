/* Prepare answers to the following questions:

• How can one restrict access to certain columns of a database table?:

    This can be done by using Column-Level Security. It is used to  grant access to 
    particular columns only to the intended user.
    
    For instance, GRANT SELECT (empno, ename, address) ON employee TO admin;
    The above query grants the admin only access to the empno, ename and address columns only.


• What is the difference between user identification and user authentication?:
    User Identification or User ID is an entity used to identify a user in the database 
    while User Authentication is the process of validating an identity (User ID).

• What are the recommended authentication protocols for PostgreSQL?
    * Password Authentication (SCRAM-SHA-256)
    * Trust Authentication
    * Ident Authentication
    * GSSAPI Authentication
    * Peer Authentication
    * Lightweight Directory Access Protocol (LDAP) Authentication
    * 

• What is proxy authentication in PostgreSQL and what is it for?
 Why does it make the previously discussed role-based access control easier to 
implement?

 *  Proxy Authentication is using the database's role system to ensure that the user who uses the application 
 *  is authorized to perform a certain task usually by delegating the authentication to another role after the 
 *  connection is established or reused. It is done using the SET SESSION AUTHORIZATION statement or SET ROLE 
 *  command in a transaction block.
 * 
 *  For instance, SELECT session_user, current_user; -- current user is postgres
 *                SET SESSION AUTHORIZATION test user -- it sets the present connection to another user
 * 
 *  It makes the previously discussed role-based access control easier to implement because a user can use 
 *  the priviledges of the session owner without having to declare them again.
 */