<?php
/*
Plugin Name: PoorIO default WordPress settings
Plugin URI: http://poor.io/
Description: Readjusts default settings.
Version: 0.9
Author: Brian Zalewski
Author URI: http://poor.io/
*/

function poor_io_defaults()
{
    $o = array(
        'avatar_default' => 'mystery',
        'avatar_rating' => 'G',
        'category_base' => '/%category%/',
        'comments_notify' => 0,
        'comment_max_links' => 1,
        'comments_per_page' => 10,
        'date_format' => 'j. F Y, H:i',
        'default_ping_status' => 'open',
        'default_post_edit_rows' => 30,
        'gmt_offset' => -4,
        'links_updated_date_format' => 'j. F Y, H:i',
        'permalink_structure' => '/%post_id%/%postname%',
        'rss_language' => 'en',
        'tag_base' => '/tag/',
        'use_smilies' => 0,
    );

    foreach ( $o as $k => $v )
    {
        update_option($k, $v);
    }

    // Delete dummy post and comment.
    wp_delete_post(1, TRUE);
    wp_delete_comment(1);

    return;
}
register_activation_hook(__FILE__, 'poor_io_defaults'); // Fires when plugin is activated
?>







function toggle_plugin() {

// Full path to WordPress from the root
$wordpress_path = '/full/path/to/wordpress/';

// Absolute path to plugins dir
$plugin_path = $wordpress_path.'wp-content/plugins/';

// Absolute path to your specific plugin
$my_plugin = $plugin_path.'my_plugin/my_plugin.php';

// Check to see if plugin is already active
if(is_plugin_active($my_plugin)) {

// Deactivate plugin
// Note that deactivate_plugins() will also take an
// array of plugin paths as a parameter instead of
// just a single string.
deactivate_plugins($my_plugin);
}
else {

// Activate plugin
activate_plugin($my_plugin);
}
}
