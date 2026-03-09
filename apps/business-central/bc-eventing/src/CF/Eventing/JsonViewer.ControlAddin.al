namespace CF.Eventing;

controladdin JsonViewer
{
    StartupScript = 'src/_resources/scripts/json-viewer-startup.js';
    Scripts = 'src/_resources/scripts/json-viewer.js', 'src/_resources/scripts/json-viewer-functions.js';
    StyleSheets = 'src/_resources/stylesheets/json-viewer.css';

    HorizontalStretch = true;
    HorizontalShrink = true;
    MinimumWidth = 250;

    VerticalShrink = true;
    VerticalStretch = true;
    RequestedHeight = 550;

    event OnControlAddInReady();
    event OnJsonViewerReady();
    procedure InitializeControl();
    procedure LoadDocument(data: JsonObject; maxLvl: Integer; colAt: Integer);
}