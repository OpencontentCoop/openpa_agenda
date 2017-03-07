{ezscript_require( array('addtocalendar.min.js' ) )}
<div class="row">
    <div class="col-md-12">
        <span class="addtocalendar atc-style-blue">
            <var class="atc_event">
            <var class="atc_date_start">2017-05-04 12:00:00</var>
            <var class="atc_date_end">2017-05-04 18:00:00</var>
            <var class="atc_timezone">Europe/London</var>
            <var class="atc_title">Star Wars Day Party</var>
            <var class="atc_description">May the force be with you</var>
            <var class="atc_location">Tatooine</var>
            <var class="atc_organizer">Luke Skywalker</var>
            <var class="atc_organizer_email">luke@starwars.com</var>
        </var>
        </span>
    </div>
</div>
{literal}
    <script type="text/javascript">(function () {
            if (window.addtocalendar)if(typeof window.addtocalendar.start == "function")return;
            if (window.ifaddtocalendar == undefined) { window.ifaddtocalendar = 1;
                var d = document, s = d.createElement('script'), g = 'getElementsByTagName';
                s.type = 'text/javascript';s.charset = 'UTF-8';s.async = true;
                s.src = ('https:' == window.location.protocol ? 'https' : 'http')+'://addtocalendar.com/atc/1.5/atc.min.js';
                var h = d[g]('body')[0];h.appendChild(s); }})();
    </script>
{/literal}