<?php
	error_reporting(E_ALL);
	ini_set('display_errors', '1');
	if (!empty($_FILES)) {
		include 'upload.php';
	}
?>
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">
    <title>Segmentador</title>
    <link href="bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.0/jquery-confirm.min.css">
    <link href="estilo.css" rel="stylesheet">
  </head>

  <body>

    <nav class="navbar navbar-inverse navbar-fixed-top">
		<div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Segmentador</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Inicio</a></li>
            <!--li><a href="#about">Ayuda</a></li>
            <li><a href="#contact">Contacto</a></li-->
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>

    <div class="container-full">
		<img class="object-fit_none" src="img/segmentation3.png" />
		<div class="starter-template">
			<h1>Segmentación automática</h1>
			<p class="lead">Use esta aplicación para segmentar sus shapes.<br><!--Envíe su shape desde el formulario y reciba un nuevo archivo con la segmentación.--></p>
		</div>
	</div>
	<div class="container">
		<div class="col-md-6">
			<form class="form" method="post" action="" enctype="multipart/form-data">
				<div class="form-group">
					<label for="file">ZIP con cobertura de ejes y manzanas</label>
					<input type="file" class="form-control" id="zip" name='file_zip' >
				</div>
				<div class="form-group">
					<label for="file">CSV</label>
					<input type="file" class="form-control" id="zip" name='file_csv' >
				</div>
				<div class="form-group">
					<label for="maximum">Cantidad de viviendas deseada por segmento</label>
					<input type="text" class="form-control" id="cantidad_de_viviendas_deseada_por_segmento" name='cantidad_de_viviendas_deseada_por_segmento' >
				</div>
				<div class="form-group">
					<label for="minimum">Cantidad de viviendas mínima por segmento</label>
					<input type="text" class="form-control" id="cantidad_de_viviendas_minima_por_segmento" name='cantidad_de_viviendas_minima_por_segmento' >
				</div>
				<div class="form-group">
					<label for="maximum">Cantidad de viviendas maxima por segmento</label>
					<input type="text" class="form-control" id="cantidad_de_viviendas_maxima_por_segmento" name='cantidad_de_viviendas_maxima_por_segmento' >
				</div><br>
				<div class="form-group">
					<label for="maximum">Cantidad máxima de segmentos</label>
					<input type="text" class="form-control" id="cantidad_maxima_de_segmentos" name='cantidad_maxima_de_segmentos' >
				</div>
				<div class="form-group">
					<label for="maximum">Fracción/Radio</label>
					<input type="text" class="form-control" id="fraccion_radio" name='fraccion_radio' >
				</div>
				<button type="submit" class="btn btn-default">Enviar</button>
			</form>	
		
		</div>
		<div class="col-md-6"></div>
		
		

				<div class="col-md-12">
					<hr>
					<h2>Instructivo</h2>
					<?php include 'instructivo.php'; ?>
				</div>

		
		
		<!--footer class="footer text-center">
			<div class="navbar navbar-inverse">
				<div class="navbar-inner">
					<div class="container">
						<span>Geoestaditíca INDEC - 2017</span>
					</div>
				</div>
			</div>
		</footer-->
		
    </div><!-- /.container -->
	


    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="../../assets/js/vendor/jquery.min.js"><\/script>')</script>
    <script src="bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.0/jquery-confirm.min.js"></script>

		<script>
			var responseUpload = <?php echo $respuestaUpload; ?>;
			if(responseUpload['state']=='ok') {
				var message = responseUpload['message'] + "<br><a href='zip.php?path=<?php echo $ficheroSubido; ?>' target='_blank' >Descarga</a>";
			} else {
				var message = responseUpload['message'] ;
			}
			$(function() { 
				$.alert({
					title: 'Subida de archivos',
					content: message,
				});
			});
		</script>
  
  </body>
</html>
