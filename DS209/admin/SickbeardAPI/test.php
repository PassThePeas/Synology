<?php

        //SickBeard Refresh Script by Marty Strong
        //Martystrong.co.uk



        //Sickbeard URL Including Port e.g. 'http://localhost:8081"
        $url = "http://localhost:8081";
        //Sickbeard API Key
        $api = "5bdef779023764f936d33a98fa8c41c5";
        //Sickbeard API URL
        $apiURL = $url."/api/".$api."/";

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

        function runRescan($apiURL)
        {
                //Sickbeard API GetShows Call
                $showsCMD = "?cmd=shows";
                //Download Sickbeard API Output
                $string = get_content($apiURL.$showsCMD);
                //Decode JSON from API
                $json_a = json_decode($string,true);
                //Get show keys
                $keys = array_keys($json_a['data']);
                //Get amount of show keys
                $size = count($keys);
                //For every show trigger a refresh
                for ($i = 0; $i <= $size -1; $i++)
                {
                        //Sickbeard API Infos Show Call
                        $showCMD = "?cmd=show&tvdbid=$keys[$i]";
                        echo get_content($apiURL.$showCMD);
                }

        }
        runRescan($apiURL);
?>
