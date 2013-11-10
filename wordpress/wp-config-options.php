<?php


/* ***************************************** */
/* SECURITY CREDENTIALS AND SETTINGS */
/* ***************************************** */


/* Database connection settings */
define( 'DB_NAME', 'DB_NAME_HANDLE' );
define( 'DB_USER', 'DB_USER_HANDLE' );
define( 'DB_PASSWORD', 'DB_PASSWORD_HANDLE' );
define( 'DB_HOST', $_ENV{DATABASE_SERVER} ); // Dynamically sets the database host
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/* Custom database format */
$table_prefix = 'TABLE_PREFIX_HANDLE_';
// define( 'CUSTOM_USER_TABLE', $table_prefix . 'CUSTOM_USER_TABLE_HANDLE' );
// define( 'CUSTOM_USER_META_TABLE', $table_prefix . 'CUSTOM_USER_META_TABLE_HANDLE' );

/* SSL (HTTPS) settings */
// define( 'FORCE_SSL_LOGIN', TRUE );
// define( 'FORCE_SSL_ADMIN', TRUE );

/* Authentication keys and salts */
// Key generator tool: https://api.wordpress.org/secret-key/1.1/salt/
define( 'AUTH_KEY', 'put your unique phrase here' );
define( 'SECURE_AUTH_KEY', 'put your unique phrase here' );
define( 'LOGGED_IN_KEY', 'put your unique phrase here' );
define( 'NONCE_KEY', 'put your unique phrase here' );
define( 'AUTH_SALT', 'AUTH_SALT_HANDLE' );
define( 'SECURE_AUTH_SALT', 'SECURE_AUTH_SALT_HANDLE' );
define( 'LOGGED_IN_SALT', 'LOGGED_IN_SALT_HANDLE' );
define( 'NONCE_SALT', 'NONCE_SALT_HANDLE' );

/* Security tweaks */
define( 'DISALLOW_FILE_MODS', TRUE ); // Experiment with this for security purposes:
define( 'DISALLOW_UNFILTERED_HTML', TRUE ); // Disallow unfiltered_html for all users, even admins and super admins
define( 'ALLOW_UNFILTERED_UPLOADS', TRUE ); // Allow uploads of filtered file types to users with administrator role
define( 'WP_HTTP_BLOCK_EXTERNAL', FALSE ); // Do not block internet requests
// define( 'WP_ACCESSIBLE_HOSTS', 'api.wordpress.org'); // Whitelist hosts for when WP_HTTP_BLOCK_EXTERNAL is true


/* ***************************************** */
/* LANGUAGE AND DIRECTORY STRUCTURE SETTINGS */
/* ***************************************** */


/* Localized language */
define( 'WPLANG', '' ); // U.S. English (en_US) by default
// define( 'WP_LANG_DIR', dirname(__FILE__) . '/languages');

/* Theme settings */
define('WP_DEFAULT_THEME', 'roots' );
// define('TEMPLATEPATH', '/absolute/path/to/wp-content/themes/active-theme');
// define('STYLESHEETPATH', '/absolute/path/to/wp-content/themes/active-theme');

/* Directory structure settings */
define( 'WP_SITEURL', 'http://' . $_SERVER['SERVER_NAME'] . '/cms'); // Defines the site URL to minimize database transactions
define( 'WP_HOME', 'http://' . $_SERVER['SERVER_NAME'] ); // Defines home URL to minimize database transactions
define( 'WP_CONTENT_DIR', dirname( __FILE__ ) . '/content' ); // Custom content directory
define( 'WP_CONTENT_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/content' );
define( 'WP_PLUGIN_DIR', dirname( __FILE__ ) . '/addons' ); // Custom plugin directory
define( 'WP_PLUGIN_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/addons' );
define( 'PLUGINDIR', WP_PLUGIN_DIR ); // For compatibility with older scripts
define( 'WPMU_PLUGIN_DIR', dirname( __FILE__ ) . '/includes' ); // Custom must-use plugin directory
define( 'WPMU_PLUGIN_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/includes' );
define( 'UPLOADS', '/media' ); // Upload directory relative to WP install directory


/* ***************************************** */
/* MULTISITE AND COOKIE SETTINGS */
/* ***************************************** */


/* Multisite settings */
define( 'WP_ALLOW_MULTISITE', FALSE ); // Allow multisite
define( 'MULTISITE', FALSE ); // Network setup (FIDDLE WITH THIS FOR QUERY REDUCTION)

/* Cookie settings */
/*
define( 'ADMIN_COOKIE_PATH', '/' );
define( 'COOKIE_DOMAIN', FALSE ); // Important for multisite without domain mapping plugin
define( 'COOKIEPATH', '' );
define( 'SITECOOKIEPATH', '' );
*/


/* ***************************************** */
/* DEBUG SETTINGS */
/* ***************************************** */


define( 'CURRENT_SERVER', 'dev' ); // Set to dev for developement settings and live for production settings

switch( CURRENT_SERVER ){
        
case 'dev': // Development debug settings
        define( 'WP_CACHE', FALSE );
        define( 'WP_DEBUG', TRUE );
        define( 'DISALLOW_FILE_EDIT', FALSE );
        define( 'SAVEQUERIES', TRUE );
        /*
View queries in the footer of your theme with the following snippet:
<?php
if ( current_user_can( 'administrator' ) ) {
global $wpdb;
echo "<pre>";
print_r( $wpdb->queries );
echo "</pre>";
}
?>
// Random notes: print_r(@get_defined_constants()); // prints all php constants
// One line version: <?php if (current_user_can('level_10')) { global $wpdb; echo "<pre>"; print_r($wpdb->queries); echo "</pre>"; } ?>
*/
        error_reporting(E_ALL | E_WARNING | E_ERROR);
        // display errors
        @ini_set('log_errors','Off');
        @ini_set('display_errors','On');
        // Notes on this ini_set stuff: http://digwp.com/2009/07/monitor-php-errors-wordpress/
        // @ini_set('error_log','/home/path/domain/logs/php_error.log');
        define( 'WP_DEBUG_LOG', TRUE );
        define( 'WP_DEBUG_DISPLAY', TRUE );
        define( 'SCRIPT_DEBUG', TRUE );
        
case 'live': // Production debug settings
        define( 'WP_CACHE', TRUE );
        define( 'WP_DEBUG', FALSE );
        define( 'DISALLOW_FILE_EDIT', TRUE );
        define( 'SAVEQUERIES', FALSE );
        error_reporting(E_WARNING | E_ERROR);
        // log errors in a file (content/debug.log), don't show them to end-users.
        @ini_set('log_errors','On');
        @ini_set('display_errors','Off');
        define( 'WP_DEBUG_LOG', TRUE );
        define( 'WP_DEBUG_DISPLAY', FALSE );
        define( 'SCRIPT_DEBUG', FALSE );

        break;
}


/* ***************************************** */
/* CONTENT AND PERFORMANCE SETTINGS */
/* ***************************************** */


/* Content settings */
// define( 'WP_POST_REVISIONS', FALSE ); // Disables post revisions
define( 'WP_POST_REVISIONS', 5 ); // Total revisions to keep per post
define( 'AUTOSAVE_INTERVAL', 180 ); // Number of seconds inbetween autosaves
define( 'MEDIA_TRASH', TRUE ); // Enable trash for media
define( 'EMPTY_TRASH_DAYS', 14 ); // Empty trash every X days

/* Memory settings */
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '512M' );

/* Performance tweaks */
// Compression for JS and styles - supposedly these slow down your website. Regardless, we use pagespeed so let's turn these off
define( 'CONCATENATE_SCRIPTS', FALSE );
define( 'COMPRESS_SCRIPTS', FALSE );
define( 'COMPRESS_CSS', FALSE );
define( 'ENFORCE_GZIP', FALSE );


/* ***************************************** */
/* FTP AND PROXY CONNECTION SETTINGS */
/* ***************************************** */


/* Proxy settings */
/*
define( 'WP_PROXY_HOST', '10.28.123.4' );
define( 'WP_PROXY_PORT', '8080' );
define( 'WP_PROXY_USERNAME', 'username123' );
define( 'WP_PROXY_PASSWORD', 'password123' );
define( 'WP_PROXY_BYPASS_HOSTS', 'localhost' );
*/

/* FTP settings */
/*
define( 'FTP_HOST', '' );
define( 'FTP_USER', 'username123' );
define( 'FTP_PASS', 'password123' );
define( 'FTP_SSL', FALSE );
*/


/* ***************************************** */
/* UPDATE SETTINGS */
/* ***************************************** */


define( 'CORE_UPGRADE_SKIP_NEW_BUNDLED', TRUE ); // Skip content directory when upgrading to a new WordPress version
define( 'DISALLOW_FILE_MODS', TRUE ); // Disables file modifications - NOTE: Find out if this over-rides DISALLOW_FILE_EDIT


/* Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/BACKEND_PATH_HANDLE/');

/* Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
