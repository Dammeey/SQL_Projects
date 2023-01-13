-- Figure out what security precautions are already used in your 'dvd_rental' database; 
-- send description

/* pg_signal_backend : It gives the admin the ability to grant non-superuser roles 
 *                      the ability to send signals to other backends. It also permits the sending of signals
 *                       to cancel or stop a backend query's session.
 * 
 * 
 * 
 *  pg_read_server_files: This role enables the admin to provide trustworthy, non-superuser roles 
 *                      that have access to files and can execute programs on the database server as the user 
 *                      that the database is running as.   
 *                      The role allows reading files from any location the database can access on the server 
 *                      with COPY and other file-access functions.
 *
 *
 *  pg_write_server_files: Just like the pg_read_server_files, this role also enables the admin to provide 
 *                      trustworthy, non-superuser roles that have access to files and can execute programs 
 *                      on the database server as the user that the database is running as.   
 *                      However, it allows writing to files in any location the 
 *                      database can access on the server with COPY and other file-access functions.
 * 
 * 
 * postgres : The postgres role is the database administrator/owner with access to all the permissions and 
 *              policies in the database
 * 
 * 
 *  pg_execute_server_program:  The role allows server-side programs to be run on the database server as 
 *                              the user that the database is currently running as when using COPY 
 *                              and other operations.   
 
 * 
 *  pg_read_all_stats:  The pg_read_all_stats allows the user to view and use various statistics related 
 *                      extensions, even those normally visible only to superusers.
 * 
 * 
 *  pg_monitor: It allows access to read/execute various monitoring views and functions. 
 *              This role is also a member of pg_read_all_settings, pg_read_all_stats and pg_stat_scan_tables.
 * 
 * 
 * pg_read_all_settings:  The role allows access to read all configuration variables, 
 *                          even those normally visible only to superusers.   
 * 
 * 
 * pg_stat_scan_tables: It allows access to execute monitoring functions that may take 
 *                      ACCESS SHARE locks on tables, potentially for a long time.    
 * 
 */  
