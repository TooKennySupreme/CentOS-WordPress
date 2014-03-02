<?php

/* ***************************************** */
/* SECURITY CREDENTIALS AND SETTINGS */
/* ***************************************** */

/* Database connection settings */
define( 'DB_NAME', '{DATABASE_NAME}' );
define( 'DB_USER', '{DATABASE_USER}' );
define( 'DB_PASSWORD', '{DATABASE_PASSWORD}' );
define( 'DB_HOST', 'localhost' );
//define( 'DB_HOST', $_ENV{DATABASE_SERVER} ); // Dynamically sets the database host - disabled since WP-CLI doesn't like it
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/* Custom database format */
$table_prefix = '{DATABASE_PREFIX}_';
// define( 'CUSTOM_USER_TABLE', $table_prefix . 'CUSTOM_USER_TABLE_HANDLE' );
// define( 'CUSTOM_USER_META_TABLE', $table_prefix . 'CUSTOM_USER_META_TABLE_HANDLE' );

/* SSL (HTTPS) settings */
// define( 'FORCE_SSL_LOGIN', TRUE );
// define( 'FORCE_SSL_ADMIN', TRUE );

/* Authentication keys and salts */
// Key generator tool: https://api.wordpress.org/secret-key/1.1/salt/
{AUTH-KEYS-SALTS}

/* Security tweaks */
define( 'DISALLOW_FILE_MODS', TRUE ); 					// Experiment with this for security purposes:
define( 'DISALLOW_UNFILTERED_HTML', TRUE ); 			// Disallow unfiltered_html for all users
define( 'ALLOW_UNFILTERED_UPLOADS', TRUE ); 			// Allow uploads of filtered file types to admins
define( 'WP_HTTP_BLOCK_EXTERNAL', FALSE ); 				// Do not block internet requests
// define( 'WP_ACCESSIBLE_HOSTS', 'api.wordpress.org'); // Whitelist hosts for when WP_HTTP_BLOCK_EXTERNAL is true

/* ***************************************** */
/* LANGUAGE AND DIRECTORY STRUCTURE SETTINGS */
/* ***************************************** */

/* Localized language */
define( 'WPLANG', '' ); // U.S. English (en_US) by default
// define( 'WP_LANG_DIR', dirname(__FILE__) . '/languages');

/* Theme settings */
define('WP_DEFAULT_THEME', '{DEFAULT_THEME}' );
// define('TEMPLATEPATH', '/absolute/path/to/wp-content/themes/active-theme');
// define('STYLESHEETPATH', '/absolute/path/to/wp-content/themes/active-theme');

/* Directory structure settings */
define( 'WP_SITEURL', 'http://' . $_SERVER['SERVER_NAME'] ); 	// Defines the site URL to minimize database transactions
define( 'WP_HOME', 'http://' . $_SERVER['SERVER_NAME'] ); 		// Defines home URL to minimize database transactions
define( 'WP_CONTENT_DIR', dirname( __FILE__ ) . '/content' ); 	// Custom content directory
define( 'WP_CONTENT_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/content' );
define( 'WP_PLUGIN_DIR', dirname( __FILE__ ) . '/addons' ); 	// Custom plugin directory
define( 'WP_PLUGIN_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/addons' );
define( 'PLUGINDIR', WP_PLUGIN_DIR ); 							// For compatibility with older scripts
define( 'WPMU_PLUGIN_DIR', dirname( __FILE__ ) . '/includes' ); // Custom must-use plugin directory
define( 'WPMU_PLUGIN_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/includes' );
define( 'UPLOADS', '/media' ); 									// Upload directory relative to WP install directory

/* ***************************************** */
/* 		MULTISITE AND COOKIE SETTINGS 		 */
/* ***************************************** */

/* Multisite settings */
define( 'WP_ALLOW_MULTISITE', TRUE ); 		// Allow multisite
// define( 'MULTISITE', TRUE ); 		// Network setup (FIDDLE WITH THIS FOR QUERY REDUCTION)
// define( 'SUBDOMAIN_INSTALL', TRUE );

/* Cookie settings */
define( 'ADMIN_COOKIE_PATH', '/' );
define( 'COOKIE_DOMAIN', '' ); // Important for multisite without domain mapping plugin
define( 'COOKIEPATH', '' );
define( 'SITECOOKIEPATH', '' );

/* ***************************************** */
/* CONTENT AND PERFORMANCE SETTINGS */
/* ***************************************** */

/* Content settings */
// define( 'WP_POST_REVISIONS', FALSE ); 	// Disables post revisions
define( 'WP_POST_REVISIONS', 5 ); 			// Total revisions to keep per post
define( 'AUTOSAVE_INTERVAL', 180 ); 		// Number of seconds inbetween autosaves
define( 'MEDIA_TRASH', TRUE ); 				// Enable trash for media
define( 'EMPTY_TRASH_DAYS', 14 ); 			// Empty trash every X days

/* Memory settings */
define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '512M' );

/* Performance tweaks */
// Compression for JS and styles. We use PageSpeed so let's turn these off.
define( 'CONCATENATE_SCRIPTS', FALSE );
define( 'COMPRESS_SCRIPTS', FALSE );
define( 'COMPRESS_CSS', FALSE );
define( 'ENFORCE_GZIP', FALSE );

/* ***************************************** */
/* FTP AND PROXY CONNECTION SETTINGS */
/* ***************************************** */

/* Proxy settings */
// define( 'WP_PROXY_HOST', '10.28.123.4' );
// define( 'WP_PROXY_PORT', '8080' );
// define( 'WP_PROXY_USERNAME', 'username123' );
// define( 'WP_PROXY_PASSWORD', 'password123' );
// define( 'WP_PROXY_BYPASS_HOSTS', 'localhost' );

/* FTP settings */
// define( 'FTP_HOST', '' );
// define( 'FTP_USER', 'username123' );
// define( 'FTP_PASS', 'password123' );
// define( 'FTP_SSL', FALSE );

/* ***************************************** */
/* UPDATE SETTINGS */
/* ***************************************** */

define( 'CORE_UPGRADE_SKIP_NEW_BUNDLED', TRUE ); // Skip content directory when upgrading to a new WordPress version

/* Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) );

/* Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
