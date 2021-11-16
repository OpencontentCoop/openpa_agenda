{literal}
    <style>
        .flyer-body {
            font-family: "Arial", "Helvetica", sans-serif;
            font-size:10pt;
        }

        /* Control page rendring: please refer to doc/doc.txt */
        @page {
            /*size: a4 portrait;*/
            size: a4 landscape;
            margin: .05in;
            @top-left {
                content: element(header);
            }
            @bottom-right {
                content: element(footer);
            }
        }

        .flyer-body p{
            margin: 0;
        }

        .flyer-body a{
            color:#000;
            text-decoration:none;
        }

        .flyer-body hr{
            background: #000;
            height: 1px;
            border: none;
        }

        .flyer-body table.event-container{
            margin-bottom: 0;
        }
        .flyer-body table.event-container tr:first-child td{
            border:none;
        }
        .flyer-body table.event-container tr td {
            border-top: 1px solid #dddddd;
        }

        .flyer-body table {
            max-width: 100%;
            background-color: transparent;
            border-collapse: collapse;
            border-spacing: 0;
        }

        .flyer-body .table {
            width: 100%;
            margin-bottom: 20px;
        }

        .flyer-body table td {
            vertical-align: top !important;
        }

        .flyer-body .table th,
        .flyer-body .table td {
            padding: 5px;
            text-align: left;
            vertical-align: top !important;
            border-top: 10px solid #dddddd;
        }

        .flyer-body .table th {
            font-weight: bold;
        }

        .flyer-body .table thead th {
            vertical-align: bottom;
        }

        .flyer-body .table caption + thead tr:first-child th,
        .flyer-body .table caption + thead tr:first-child td,
        .flyer-body .table colgroup + thead tr:first-child th,
        .flyer-body .table colgroup + thead tr:first-child td,
        .flyer-body .table thead:first-child tr:first-child th,
        .flyer-body .table thead:first-child tr:first-child td {
            border-top: 0;
        }

        .flyer-body .table tbody + tbody {
            border-top: 2px solid #dddddd;
        }

        .flyer-body .table .table {
            background-color: #ffffff;
        }


        .flyer-body table {
            page-break-inside:auto;
            width: 100%;
        }
        .flyer-body tr {
            page-break-inside:avoid;
            page-break-after:auto
        }

        .flyer-body ul,
        .flyer-body ol {
            margin: 0;
            list-style: none;
            padding:0;
        }

        .flyer-body ul.inline,
        .flyer-body ol.inline {
            margin-left: 0;
            list-style: none;
        }

        .flyer-body ul.inline > li,
        .flyer-body ol.inline > li {
            display: inline-block;
            padding-right: 5px;
            padding-left: 5px;
        }

        .flyer-body .columns-2 {
            width: 50%;
            padding: 0 20px;
        }

        .flyer-body .columns-3 {
            width: 30%;
            padding: 0 20px;
        }

        .flyer-body .text-center {
            text-align: center;
        }

        .flyer-body .event-abstract{
            font-size: .8em;
        }

        .flyer-body.layout-2 *{
            font-size:8pt !important;
        }

        .flyer-body.layout-2 h4{
            margin: 5px 0;
        }

        .flyer-body.layout-2 .event-abstract{
            line-height:1.5;
            font-size:8pt !important;
        }

        .flyer-body.layout-2 .table td {
            padding: 8pt;
        }

        .flyer-body.layout-3 *{
            font-size:8pt !important;
        }

        .flyer-body.layout-3 h4{
            margin: 5px 0;
        }

        .flyer-body.layout-3 .event-abstract{
            line-height:1.5;
            font-size:8pt !important;
        }

        .flyer-body.layout-3 .table td {
            padding: 8px;
        }

        .flyer-body.layout-4 *{
            font-size:8pt !important;
            line-height: normal;
        }
        .flyer-body.layout-4 small{
            font-size:10pt !important;
        }

        .flyer-body.layout-4 h4{
            margin: 0;
            font-size:10pt !important;
        }

        .flyer-body.layout-4 .event-abstract{
            line-height:normal;
            font-size:8pt !important;
        }

        .flyer-body.layout-4 .table td {
            padding: 5px;
        }

        .flyer-body #copertina h1.title{
            text-transform: uppercase;
            font-size: 16pt !important;
        }

        .flyer-body #copertina h3.subtitle{
            font-size: 14pt !important;
        }

        .flyer-body #copertina div.contacts{
            text-align:center;
            line-height:1.5;
        }

    </style>
{/literal}
