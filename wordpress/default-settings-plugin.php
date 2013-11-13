<?php
/*
Plugin Name: GigabyteIO default WordPress settings and installer
Plugin URI: http://gigabyte.io/
Description: Readjusts default settings and activates plugins
Version: 0.9
Author: Brian Zalewski
Author URI: http://gigabyte.io/
*/

function gigabyteio_defaults()
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


function toggle_plugins() {
// Defines plugins to be activated
$arr = array("one", "two", "three");
// Full path to WordPress from the root
$website_base = 'INSERTWEBSITEBASEHERE'
$wordpress_path = '/full/path/to/wordpress/';

// Absolute path to plugins dir
$plugin_path = $wordpress_path.'addons/';
foreach ($arr as $value) {
// Absolute path to your specific plugin
$my_plugin = $plugin_path.$value;

// 
if(is_plugin_active($my_plugin)) {

// Deactivate plugin
// Note that deactivate_plugins() will also take an
// array of plugin paths as a parameter instead of
// just a single string.
echo "$value is already active.";
}
else {

// Activate plugin
activate_plugin($my_plugin);
}
}
}
// register_activation_hook(__FILE__, 'toggle_plugins');
register_activation_hook(__FILE__, 'gigabyteio_defaults'); // Fires when this plugin is activated
?>
