<?php
$path = $_GET['path'];

$file_name = basename($path);

header("Content-Type: application/zip");
header("Content-Disposition: attachment; filename=$file_name");
header("Content-Length: " . filesize($path));

readfile($path);
exit;