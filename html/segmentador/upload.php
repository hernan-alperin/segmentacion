<?php
	$dir_subida = 'shapes/';
    $zipFile = $_FILES['file_zip']['name'];
	$ficheroSubido = $dir_subida . $zipFile;
	 
	if (move_uploaded_file($_FILES['file_zip']['tmp_name'], $ficheroSubido)) {
		$res = ['state'=>'ok', 'message'=>"Ok. El archivo subió con éxito."];
		//fileZip($ficheroSubido);
	} else {
		$res = ['state'=>'error', 'message'=>"Error. No se pudo subir el archivo.", 'file'=>$ficheroSubido];
	}

    include_once 'procesar.php';
    if ($res['state'] == 'ok') {
        $resultado = procesar($ficheroSubido);
        if ($resultado == 'ok') {
            $respuestaUpload = ['state'=>'ok', 'message'=>"Ok. El archivo se procesó con éxito."];
        } else {
            $respuestaUpload = ['state'=>'error', 'message'=>$resultado];
        }    
    }
    $respuestaUpload = json_encode($respuestaUpload);



