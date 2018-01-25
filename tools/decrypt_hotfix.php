<?php
define(ENCRYPT_TAG, 'pokdeng@boyaa2015');
define(ENCRYPT_KEY, 'PokDeng655355');

$quick_cocos2dx_root = getenv("QUICK_V3_ROOT");
require_once($quick_cocos2dx_root . 'quick/bin/lib/quick/xxtea.php');

$xxtea = new XXTEA();
$xxtea->setKey(ENCRYPT_KEY);	

$file = "game.zip";
$content = file_get_contents($file);

echo "\nSTART!\n";
if(substr($content, 0, strlen(ENCRYPT_TAG)) == ENCRYPT_TAG)
{		
	$content = substr($content, strlen(ENCRYPT_TAG));
	$str = $xxtea->decrypt($content);
	file_put_contents($file, $str);
	echo "\nDONE!\n";
}
echo "\nEND!\n";
