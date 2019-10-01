{def $social_pagedata = social_pagedata('agenda')}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
	<title>{$title}</title>
	<style type="text/css">
  {literal}  
    @import url('http://fonts.googleapis.com/css?family=Open+Sans');
    body{font-family: 'Open Sans', 'Arial', 'Helvetica', sans-serif;}
		#outlook a {padding:0;}
		body{width:100% !important; -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%; margin:0; padding:0;}		
		.ExternalClass {width:100%;}
		.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {line-height: 100%;}
		#backgroundTable {margin:0; padding:0; width:100% !important; line-height: 100% !important;}
		img {outline:none; text-decoration:none; -ms-interpolation-mode: bicubic;}
		a img {border:none;}
		.image_fix {display:block;}
		p {margin: 1em 0;}
		h1, h2, h3, h4, h5, h6 {color: black !important;}
		h1 a, h2 a, h3 a, h4 a, h5 a, h6 a {color: blue !important;}
		h1 a:active, h2 a:active,  h3 a:active, h4 a:active, h5 a:active, h6 a:active {
			color: red !important; /* Preferably not the same color as the normal header link color.  There is limited support for psuedo classes in email clients, this was added just for good measure. */
		 }
		h1 a:visited, h2 a:visited,  h3 a:visited, h4 a:visited, h5 a:visited, h6 a:visited {
			color: purple !important; /* Preferably not the same color as the normal header link color. There is limited support for psuedo classes in email clients, this was added just for good measure. */
		}
		table td {border-collapse: collapse;}
		table { border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; }
		a {color: red;}
		@media only screen and (max-device-width: 480px) {
			a[href^="tel"], a[href^="sms"] {
						text-decoration: none;
						color: black; /* or whatever your want */
						pointer-events: none;
						cursor: default;
					}
			.mobile_link a[href^="tel"], .mobile_link a[href^="sms"] {
						text-decoration: default;
						color: red !important; /* or whatever your want */
						pointer-events: auto;
						cursor: default;
					}
		}
		@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) {
			a[href^="tel"], a[href^="sms"] {
						text-decoration: none;
						color: blue; /* or whatever your want */
						pointer-events: none;
						cursor: default;
					}
			.mobile_link a[href^="tel"], .mobile_link a[href^="sms"] {
						text-decoration: default;
						color: red !important;
						pointer-events: auto;
						cursor: default;
					}
		}
		@media only screen and (-webkit-min-device-pixel-ratio: 2) {
			/* Put your iPhone 4g styles in here */
		}
		@media only screen and (-webkit-device-pixel-ratio:.75){
			/* Put CSS for low density (ldpi) Android layouts in here */
		}
		@media only screen and (-webkit-device-pixel-ratio:1){
			/* Put CSS for medium density (mdpi) Android layouts in here */
		}
		@media only screen and (-webkit-device-pixel-ratio:1.5){
			/* Put CSS for high density (hdpi) Android layouts in here */
		}
  {/literal}
	</style>

	<!--[if IEMobile 7]>
	<style type="text/css">

	</style>
	<![endif]-->

	<!--[if gte mso 9]>
	<style>
		/* Target Outlook 2007 and 2010 */
	</style>
	<![endif]-->
</head>
<body>	
	<table align='center' bgcolor='#f4f7f9' border='0' cellpadding='0' cellspacing='0' id='backgroundTable' style='background: #f4f7f9;' width='100%'>
    <tr>
        <td align='center'>
            <center>
                <table border='0' cellpadding='20' cellspacing='0' style='margin-left: auto;margin-right: auto;width:600px;text-align:center;' width='600'>
                    <tr>
                        <td align='center' valign='top'>
							<img src="http://{$social_pagedata.asset_url}{$social_pagedata.logo_path|ezroot(no)}" alt="{$social_pagedata.site_title}" {if is_header_only_logo_enabled()|not()}height="90" width="90"{/if} style="outline:none; text-decoration:none;border:none,display:block;">
                          <p>{$social_pagedata.logo_title} - {$social_pagedata.logo_subtitle}</p>
                        </td>
                    </tr>
                </table>
            </center>
        </td>
    </tr>
    <tr>
        <td align='center'>
            <center>
                {$content}
            </center>
        </td>
    </tr>
    <tr>
      <td align='center'>
            <center>
                <table border='0' cellpadding='30' cellspacing='0' style='margin-left: auto;margin-right: auto;width:600px;text-align:center;' width='600'>
                    <tr>
                        <td align='center' valign='top'>
                          <small>
                            &copy; {currentdate()|datetime('custom', '%Y')} {$social_pagedata.logo_title} -
                            {'%privacy_link_start%Privacy info%privacy_link_end%'|i18n('agenda/mail/registration',, hash( '%privacy_link_start%', concat( '<a href=http://', $social_pagedata.site_url, '/agenda/info/privacy/>' ), '%privacy_link_end%', '</a>' ))} -
                            {'%terms_link_start%Terms of use%terms_link_end%'|i18n('agenda/mail/registration',, hash( '%terms_link_start%', concat( '<a href=http://', $social_pagedata.site_url, '/agenda/info/terms/>' ), '%terms_link_end%', '</a>' ))}
                          </small>
                        </td>
                    </tr>
                </table>
            </center>
      </td>
    </tr>
</table>
</body>
</html>
