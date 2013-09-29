<?php

	//SickBeard search Script for SABnzbd post processing

	$params=parse_ini_file("/volume1/public/Scripts/SickbeardAPI/params.cnf");
	var_dump($params);

	// INPUT Params
	// 1     The final directory of the job (full path)
	// 2     The original name of the NZB file
	// 3     Clean version of the job name (no path info and ".nzb" removed)
	// 4     Indexer's report number (if supported)
	// 5     User-defined category
	// 6     Group that the NZB was posted in e.g. alt.binaries.x
	// 7     Status of post processing. 0 = OK, 1=failed verification, 2=failed unpack, 3=1+2
	function get_content($url)
	{
		$ch = curl_init();
		curl_setopt ($ch, CURLOPT_URL, $url);
		curl_setopt ($ch, CURLOPT_HEADER, 0);
		ob_start();
		curl_exec ($ch);
		curl_close ($ch);
		$string = ob_get_contents();
		ob_end_clean();
		return $string;
	}

	function read_params($inp){
		if (count($inp) < 7) {
			echo "ERROR : Not enough input parameters\n";
			exit(2);
		}

		$myInput = array(
		"JobFinalDir"			=> $inp[1],
		"NzbFileName"			=> $inp[2],
		"CleanJobName"			=> $inp[3],
		"IndexerReportNumber"	=> $inp[4],
		"Category"				=> $inp[5],
		"NzbGroup"				=> $inp[6],
		"PostProcessStatus"		=> $inp[7]
		);

		return $myInput;
	}

	function systemCall($systemCmd){
		system ($systemCmd, $returnSysCmd);
		if ($returnSysCmd <> 0) {
			echo "Erreur lors de l'appel system : >>".$systemCmd."<<\n";
			echo "returned : ".$returnSysCmd;
		}
		return $returnSysCmd;
	}

	function copyr($source, $dest)
	{
		// Check for symlinks
		if (is_link($source)) {
			return symlink(readlink($source), $dest);
		}

		// Simple copy for a file
		if (is_file($source)) {
			return copy($source, $dest);
		}

		// Make destination directory
		if (!is_dir($dest)) {
			mkdir($dest);
		}

		// Loop through the folder
		$dir = dir($source);
		while (false !== $entry = $dir->read()) {
			// Skip pointers
			if ($entry == '.' || $entry == '..') {
				continue;
			}

			// Deep copy directories
			copyr("$source/$entry", "$dest/$entry");
		}

		// Clean up
		$dir->close();
		return true;
	}

	function logToFile($log, $logFile){
		$actualDate=date("Ymd:His");
		file_put_contents($logFile, $actualDate." >> ".$log."\n", FILE_APPEND);
	}

	function human_filesize($bytes, $decimals = 2) {
		$sz = 'BKMGTP';
		$factor = floor((strlen($bytes) - 1) / 3);
		return sprintf("%.{$decimals}f", $bytes / pow(1024, $factor)) . @$sz[$factor];
	}



	// Paramètres modifiables par l'utilisateur
	$locations = array();
	$locations[0] = array("A110", "/mnt/pch_a110/Video/Series/", "/mnt/pch_a110/SAB_AUTO_TMP");
	$locations[1] = array("DS209", "/volume1/video/Series/", "/volume1/tmp/SABnzbd");
	$locations[2] = array("DS209_US2", "/volumeUSB3/usbshare/video_u/Series/", "/volumeUSB3/usbshare/public_u/SAB_AUTO_TMP");
	$locations[3] = array("DS411", "/mnt/DS411/video/Series/", "/mnt/DS411/SABnzbd/SAB_AUTO_TMP");
	$locations[4] = array("A210", "/mnt/pch_a210/Video/Series/", "/mnt/pch_a210/SAB_AUTO_TMP");
	$locations[5] = array("A210_USB", "/mnt/pch_a210_usb1/PCH_A210/Video/Series", "/mnt/pch_a210_usb1/PCH_A210/SAB_AUTO_TMP");

	//Default localtion
	$defaultLocation = $locations[0];

	//Sickbeard URL Including Port e.g. 'http://localhost:8081"
	$url = "http://" . $params["SICKBEARD_HOST"] . ":" . $params["SICKBEARD_PORT"];
	//Sickbeard API Key
	$api = $params["SICKBEARD_API_KEY"];
	//Sickbeard API URL
	$apiURL = $url."/api/".$api."/";
	// History depth to look at (# of releases in history). Note : Everything stops as soon as a releases has been found
	$historyDepth=100;
	// Limit the type of looked up releases (values : <empty=all>, &type=snatched, &type=downloaded)
	$historyType="";

	// Report path
	$reportPath = "/volume1/SABnzbd/post_processing_scripts/reports";
	// LogPath
	$logPath = "/volume1/SABnzbd/post_processing_scripts/log";

	// === MAIN ===

	//Build Full LogFile path
	$logFilePath = $logPath."/".basename($argv[0], ".php")."_".date("Ymd_His").".log";
	logToFile("Starting ...", $logFilePath);

	$input = read_params($argv);
	logToFile("Input parameters :", $logFilePath);
	$keys = array_keys($input);
	foreach ($keys as $key) {
		logToFile("* ".$key." : ".$input[$key], $logFilePath);
	}
	// Fichier report
	$reportFile = $reportPath."/".$input["CleanJobName"].".report";

	// Récupération taille répertoire
	chdir($input["JobFinalDir"]);
	$size = `/opt/bin/du -bs  | cut -f1`;

	//var_dump($input);

	logToFile("Recherche d'infos Skicbeard sur la release \"".$input["CleanJobName"]."\"", $logFilePath);
	// > History
	$historyCMD = "?cmd=history".$historyType."&limit=".$historyDepth;
	//Download Sickbeard API Output
	$string = get_content($apiURL.$historyCMD);
	//Decode JSON from API
	$json_history = json_decode($string,true);

	// Init dest information
	//$destDir = $defaultLocation[2]."/UnknownShow/".$input["CleanJobName"]."/";
	$destDir = $defaultLocation[2]."/UnknownShow/".$input["CleanJobName"];
	$archiveSuffixe = $defaultLocation[0];

	//Search input in returned shows
	foreach ($json_history['data'] as $result)
	{
		//echo "Ressource : ".$result['resource']."\n";
		if ($result['resource'] == $input["CleanJobName"]) {
			$tvdbID = $result['tvdbid'];
			//echo "====>TROUVE (tvdbid=".$tvdbID.") !!!\n";
			$showCMD = "?cmd=show&tvdbid=".$tvdbID;
			//Download Sickbeard API output
			$string = get_content($apiURL.$showCMD);
			//Decode JSON from API
			$json_showDetail = json_decode($string,true);
			//Infos
			logToFile(">> Série identifiée (tvdbid=".$tvdbID.") : ".$json_showDetail['data']['show_name']."\n", $logFilePath);
			$localisation = $json_showDetail['data']['location'];
			logToFile("Sickbeard Localisation : \"".$localisation."\"\n", $logFilePath);

			foreach ($locations as $loc) {
				echo "Compare to : \"".$loc[1]."\"\n";
				if ( strstr($localisation, $loc[1]) ) {
					// Build destination directory based on parameter (loc[2]) and Show Name
					$destDir = $loc[2]."/".$json_showDetail['data']['show_name']."/".$input["CleanJobName"];
					logToFile ("Répertoire racine de sauvegarde : \"".$destDir."\"\n", $logFilePath);
					$archiveSuffixe = $loc[0];
					break 1;				}
			}
			break 1;
		}
	}
	// Création du répertoire
	//systemCall("mkdir -p \"".$destDir."\"");
	logToFile("Creation du répertoire destination : ".$destDir, $logFilePath);
	echo "Création rep dest ".$destDir."\n";
	if (!is_dir($destDir)) {
		mkdir($destDir);
	}
	// Copie du répertoire
	logToFile("Copie des répertoires", $logFilePath);
	logToFile("* Source : ".$input["JobFinalDir"], $logFilePath);
	logToFile("* Dest : ".$destDir, $logFilePath);
	echo "Copie des répertoires\n >>Source : ".$input["JobFinalDir"]."\n >>Destination : ".$destDir."\n";
	$copie = copyr($input["JobFinalDir"], $destDir);
	// $copie = systemCall("cp -R \"".$input["JobFinalDir"]."\" \"".$destDir."\"");
	if ($copie == true) {
		logToFile("Copie des données : OK. Archivage", $logFilePath);
		echo "Copie OK, on archive\n";
		// Archivage
		$archiveDir = $input["JobFinalDir"]."/../ZZ_TRANSFERED_".$archiveSuffixe;
		if (file_exists($archiveDir)) {
			logToFile("Attention le répertoire destination \"".$archiveDir."\" existe déjà. Archivage a risque. Vérifer l'exécution.", $logFilePath);
		}

		if (!is_dir($archiveDir)) {
			mkdir($archiveDir);
		}
		$ret = systemCall("mv \"".$input["JobFinalDir"]."\" \"".$archiveDir."\"");
		if ($ret == true) {
			logToFile("Archivage : OK", $logFilePath);
		}
		else {
			logToFile("Archivage KO.", $logFilePath);
		}
	}
	else {
		logToFile("Echec de la copie des données. Pas d'archivage", $logFilePath);
	}
	logToFile("Construction du rapport", $logFilePath);
	file_put_contents($reportFile, "NZB ".$input["CleanJobName"]." (".human_filesize($size,1).")\n", FILE_APPEND);
	file_put_contents($reportFile, date("Ymd:His")." -- File moved to ".$destDir."\n", FILE_APPEND);
	file_put_contents($reportFile, date("Ymd:His")." -- File locally moved to ZZ_TRANSFERED_".$archiveSuffixe."\n", FILE_APPEND);
	logToFile("Fin des traitements", $logFilePath);

?>