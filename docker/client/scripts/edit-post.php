<?php

namespace Facebook\WebDriver;

use Facebook\WebDriver\Remote\DesiredCapabilities;
use Facebook\WebDriver\Remote\RemoteWebDriver;
use Facebook\WebDriver\WebDriverBy as By;
require_once('/vendor/autoload.php');

// start Chrome with 5 second timeout
$host = 'http://selenium-hub:4444/wd/hub';
$capabilities = DesiredCapabilities::chrome();
$driver = RemoteWebDriver::create($host, $capabilities, 5000);
set_error_handler(function ($errno , $errstr, $file, $line) use ($driver) {
    echo "$errno: $errstr at $file:$line";
    $driver->quit(); 
});
set_exception_handler(function ($ex) use ($driver) {
    echo "{$ex->getCode()}: {$ex->getMessage()}";
    echo $ex->getTraceAsString();
    $driver->quit(); 
});

echo "> When I open Wordpress login screen\n";
$driver->get('http://wordpress-sandbox.discoverops.com/wp-admin');
echo ">  And I login with username and password\n";
$driver->findElement(By::id('user_login'))->sendKeys('root');
$driver->findElement(By::id('user_pass'))->sendKeys('password')
        ->submit(); 

$header = $driver
    ->findElement(By::className('welcome-panel-content'))
    ->findElement(By::tagName('h2'));
echo "> Then I see title \"{$header->getText()}\"\n";
assert(
    $header->getText() == "Welcome to WordPress!"
) || die("\nTitle is bad");

        
echo "> When I open the Edit Post Form\n";
$driver->get(
    'http://wordpress-sandbox.discoverops.com/' .
    'wp-admin/post.php?post=1&action=edit'
);
echo ">  And I append \"hello\" to the content\n";
$driver->findElement(By::id('content_ifr'))
    ->click()
    ->sendKeys([WebDriverKeys::CONTROL, 'a'])
    ->sendKeys(WebDriverKeys::RIGHT)
    ->sendKeys(WebDriverKeys::ENTER)
    ->sendKeys('hello');

echo ">  And I publish the post\n";
$driver->findElement(By::id('publish'))
    ->click();
$message = $driver
    ->findElement(By::id('message'))
    ->findElement(By::tagName('p'));
echo "> Then I see the message \"{$message->getText()}\"\n";
assert(
    $message->getText() == "Post updated. View post"
) || die('\nMessage is bad');

$driver->quit();

