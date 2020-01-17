{ezscript_require( array( 'ezjsc::jquery', 'highcharts/charts/highcharts.js', 'highcharts/charts/modules/exporting.js' ) )}
<section class="container">
    <div class="row">
        <div class="col-lg-12 px-lg-4 py-lg-2">
            <h1>{'Statistics'|i18n('agenda/stat')}</h1>

            <div class="text-right">
                <a href="#" class="btn btn-dark btn-xs rounded-0" data-interval="monthly">{'Monthly'|i18n('agenda/stat')}</a>
                <a href="#" class="btn btn-xs rounded-0" data-interval="quarterly">{'Quarterly'|i18n('agenda/stat')}</a>
                <a href="#" class="btn btn-xs rounded-0" data-interval="half-yearly">{'Half-yearly'|i18n('agenda/stat')}</a>
                <a href="#" class="btn btn-xs rounded-0" data-interval="yearly">{'Yearly'|i18n('agenda/stat')}</a>
            </div>

            {def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
                 $close_text = 'Close'|i18n('bootstrapitalia')}

            <div class="row border-top row-column-border row-column-menu-left attribute-list mt-0">
                <aside class="col-lg-4">
                    <div class="sticky-wrapper navbar-wrapper">
                        <nav class="navbar it-navscroll-wrapper navbar-expand-lg">
                            <button class="custom-navbar-toggler" type="button" aria-controls="navbarNav"
                                    aria-expanded="false" aria-label="Toggle navigation" data-target="#navbarNav">
                                <span class="it-list"></span> {$summary_text|wash()}
                            </button>
                            <div class="navbar-collapsable">
                                <div class="overlay"></div>
                                <div class="close-div sr-only">
                                    <button class="btn close-menu" type="button">
                                        <span class="it-close"></span> {$close_text|wash()}
                                    </button>
                                </div>
                                <a class="it-back-button" href="#">
                                    {display_icon('it-chevron-left', 'svg', 'icon icon-sm icon-primary align-top')}
                                    <span>{$close_text|wash()}</span>
                                </a>
                                <div class="menu-wrapper">
                                    <div class="link-list-wrapper menu-link-list">
                                        <h3 class="no_toc">{$summary_text|wash()}</h3>
                                        <ul class="link-list">
                                            {foreach $factories as $index => $item}
                                                <li class="nav-item{if $index|eq(0)} active{/if}">
                                                    <a class="nav-link{if $index|eq(0)} active{/if}"
                                                       href="#{$item.identifier|wash()}"><span>{$item.name|wash()}</span></a>
                                                </li>
                                            {/foreach}
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </nav>
                    </div>
                </aside>
                <section class="col-lg-8">
                    {foreach $factories as $index => $item}
                        <article id="{$item.identifier|wash()}"
                                 class="it-page-section mb-2 anchor-offset">
                            <h4>{$item.name|wash()}</h4>
                            {if $item.description}
                                <p>{$item.description|wash()}</p>
                            {/if}
                            <div data-chart="{$item.identifier}" data-name="{$item.name|wash()}"
                                 data-description="{$item.description|wash()}"></div>
                        </article>
                    {/foreach}
                </section>
            </div>
        </div>
    </div>
</section>

<div id="spinner" class="hide">
    <div class="spinner text-center" style="position:absolute;width:100%;top:45%">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
        <span class="sr-only">Loading...</span>
    </div>
</div>

<div id="nodata" class="hide">
    <p class="my-3"><em>{'There is no data to produce the chart'|i18n('agenda/stat')}</em></p>
</div>

{literal}
<script type="text/javascript">
    $(function () {

        var loadChart = function (chart) {
            chart.css({'position':'relative','min-width': '310px','min-height': '600px','margin': '0 auto'}).html($('#spinner').clone().html());
            var params = {};
            $.ajax({
                dataType: "json",
                url: '/agenda/stat/' + chart.data('chart'),
                data: {
                    'ContentType': 'json',
                    'interval': $('[data-interval].btn-dark').data('interval'),
                },
                accepts: "application/json; charset=utf-8",
                success: function (response) {
                    if (response.series.length > 0) {
                        var categories = [];
                        var series = [];
                        $.each(response.intervals, function (index, value) {
                            if (value !== 'all') {
                                categories.push(value);
                            }
                        });
                        $.each(response.series, function () {
                            var seriesItem = this;
                            var item = {
                                name: seriesItem.name,
                                data: []
                            };
                            $.each(seriesItem.data, function () {
                                if (this.interval !== 'all') {
                                    item.data.push(this.count);
                                }
                            });
                            series.push(item);
                            if (response.series.length === 1) {
                                $.each(seriesItem.series, function () {
                                    var seriesChild = this;
                                    var itemChild = {
                                        name: seriesChild.name,
                                        data: []
                                    };
                                    $.each(seriesChild.data, function () {
                                        if (this.interval !== 'all') {
                                            itemChild.data.push(this.count);
                                        }
                                    });
                                    series.push(itemChild);
                                });
                            }
                        });
                        chart.highcharts({
                            chart: {
                                type: 'column'
                            },
                            xAxis: {
                                categories: categories,
                                tickmarkPlacement: 'on',
                                title: {
                                    enabled: false
                                }
                            },
                            yAxis: {
                                min: 0,
                                title: {
                                    text: '{/literal}{'Num'|i18n('agenda/chart')}{literal}'
                                },
                                stackLabels: {
                                    enabled: true,
                                    style: {
                                        fontWeight: 'bold',
                                        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
                                    }
                                }
                            },
                            tooltip: {
                                shared: true
                            },
                            plotOptions: {
                                column: {
                                    stacking: 'normal',
                                    dataLabels: {
                                        enabled: true,
                                        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white',
                                        style: {
                                            textShadow: '0 0 3px black'
                                        }
                                    }
                                }
                            },
                            title: {
                                text: chart.data('description')
                            },
                            series: series
                        });
                    }else{
                        chart.css({'min-height': 0}).html($('#nodata').clone().html());
                    }
                }
            });
        };
        $('[data-chart]').each(function () {
            loadChart($(this));
        });

        $('[data-interval]').on('click', function (e) {
            $('[data-interval]').removeClass('btn-dark');
            $(this).addClass('btn-dark');
            $('[data-chart]').each(function () {
                loadChart($(this));
            });
            e.preventDefault();
        });
    });
</script>
{/literal}
