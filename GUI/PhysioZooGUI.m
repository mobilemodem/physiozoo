function PhysioZooGUI()

% Add third-party dependencies to path
gui_basepath = fileparts(mfilename('fullpath'));
addpath(genpath([gui_basepath filesep 'lib']));
basepath = fileparts(gui_basepath);
persistent DIRS;
persistent DATA_Fig;

%rhrv_init();
%% Load default toolbox parameters
%rhrv_load_defaults --clear;

%%
%Descriptions = createDescriptions();
DATA = createData();
clearData();
GUI = createInterface();

% Now update the GUI with the current data
%updateInterface();
%redrawDemo();

% Explicitly call the demo display so that it gets included if we deploy
displayEndOfDemoMessage('');

%%-------------------------------------------------------------------------%
    function DATA = createData()
        
        screensize = get( 0, 'Screensize' );
        
        %DATA.currentDirectory = pwd;
        
        DATA.DEFAULT_WINDOW_MINUTES = Inf;
        DATA.DEFAULT_WINDOW_INDEX_LIMIT = Inf;
        DATA.DEFAULT_WINDOW_INDEX_OFFSET = 0;
        
        DATA.PlotHR = 0;
        
        DATA.rec_name = [];
        
        DATA.mammals = {'human', 'rabbit', 'mouse', 'dog', 'custom'};
        DATA.GUI_mammals = {'Human'; 'Rabbit'; 'Mouse'; 'Dog'; 'Custom'};
        DATA.mammal_index = 1;
        
        DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'Action Potential'};
        
        DATA.Integration = 'ECG';
        
        DATA.Filters = {'LowPass', 'Range', 'Quotient', 'Combined filters', 'No filtering'};
        DATA.filter_index = 1;
        
        DATA.filter_quotient = false;
        DATA.filter_lowpass = true;
        DATA.filter_range = false;
        
        if screensize(3) < 1920 %1080
            DATA.BigFontSize = 9;
            DATA.SmallFontSize = 9;
        else
            DATA.BigFontSize = 11;
            DATA.SmallFontSize = 11;
        end
        
        DATA.window_size = [screensize(3)*0.99 screensize(4)*0.85];
        
        DATA.MyGreen = [39 232 51]/256;
        
        DATA.methods = {'Lomb'; 'Welch'; 'AR'};
        DATA.default_method_index = 2;
        
        DATA.LowPassFilteringFields = [];
        DATA.PoincareFilteringFields = [];
        
        DATA.FiguresFormats = {'fig', 'bmp', 'eps', 'emf', 'jpg', 'pcx', 'pbm', 'pdf', 'pgm', 'png', 'ppm', 'svg', 'tif', 'tiff'};
        DATA.formats_index = 1;
        
        rec_colors = lines;
        DATA.rectangle_color = rec_colors(6, :);
        
        DATA.freq_yscale = 'linear';
    end % createData
%-------------------------------------------------------------------------%
%%
    function clearData()
        % All signal (Intervals)
        DATA.trr = [];
        DATA.rri = [];
        
        % All Filtered Signal (Intervals)
        DATA.tnn = [];
        DATA.nni = [];
        
        DATA.firstSecond2Show = 0;
        DATA.MyWindowSize = 900;
        DATA.maxSignalLength = 900;
        DATA.MaxYLimit = 0;
        DATA.HRMinYLimit = 0;
        DATA.HRMaxYLimit = 1000;
        DATA.RRMinYLimit = 0;
        DATA.RRMaxYLimit = 1000;
        
        %DATA.Filt_FirstSecond2Show = 0;
        DATA.Filt_MyDefaultWindowSize = 300; % sec
        %DATA.Filt_MyWindowSize = 300; % sec
        DATA.Filt_MaxSignalLength = 900;
        DATA.Filt_HRMinYLimit = 0;
        DATA.Filt_HRMaxYLimit = 1000;
        DATA.Filt_RRMinYLimit = 0;
        DATA.Filt_RRMaxYLimit = 1000;
        
        DATA.SamplingFrequency = 1000;
        
        DATA.QualityAnnotations_Data = [];
        
        DATA.FL_win_indexes = [];
        DATA.filt_FL_win_indexes = [];
        DATA.DataFileName = '';
        
        DATA.hrv_td = table;
        DATA.pd_time = struct([]);
        
        DATA.hrv_fd = table;
        DATA.pd_freq = struct([]);
        
        DATA.hrv_nl = table;
        DATA.pd_nl = struct([]);
        
        DATA.hrv_fd_lomb = table;
        DATA.hrv_fd_ar = table;
        DATA.hrv_fd_welch = table;
        
        DATA.timeData = [];
        DATA.timeRowsNames = [];
        DATA.timeDescriptions = [];
        
        DATA.fd_lombData = [];
        DATA.fd_LombRowsNames = [];
        DATA.fd_lombDescriptions = [];
        
        DATA.fd_arData = [];
        DATA.fd_ArRowsNames = [];
        
        DATA.fd_welchData = [];
        DATA.fd_WelchRowsNames = [];
        
        DATA.nonlinData = [];
        DATA.nonlinRowsNames = [];
        DATA.nonlinDescriptions = [];
        
        GUI.TimeParametersTableRowName = [];
        GUI.FrequencyParametersTableMethodRowName = [];
        GUI.NonLinearTableRowName = [];
        
        DATA.mammal = [];
        
        DATA.flag = '';
        
        DATA.formats_index = 1;
        DATA.freq_yscale = 'linear';
        
        DATA.active_window = 1;
        
        %DATA.BatchParams = DATA.DEFAULT_BatchParams;
    end
%%
    function clean_gui()
        set(GUI.DataQualityMenu,'Enable', 'off');
        set(GUI.SaveAsMenu,'Enable', 'off');
        set(GUI.SaveFiguresAsMenu,'Enable', 'off');
        set(GUI.SaveParamFileMenu,'Enable', 'off');
        set(GUI.LoadConfigFile, 'Enable', 'off');
        
        GUI.RawDataSlider.Enable = 'off';
        GUI.Filt_RawDataSlider.Enable = 'off';
        
        set(GUI.MinYLimit_Edit, 'String', '');
        set(GUI.MaxYLimit_Edit, 'String', '');
        set(GUI.WindowSize, 'String', '');
        set(GUI.FirstSecond, 'String', '');
        set(GUI.Filt_WindowSize, 'String', '');
        set(GUI.Filt_FirstSecond, 'String', '');
        
        title(GUI.RawDataAxes, '');
        
        set(GUI.RecordName_text, 'String', '');
        set(GUI.RecordLength_text, 'String', '');
        set(GUI.DataQuality_text, 'String', '');
        
        set(GUI.freq_yscale_Button, 'String', 'Log');
        set(GUI.freq_yscale_Button, 'Value', 1);
    end
%%
    function clean_gui_batch_params()
        set(GUI.batch_startTime, 'String', calcDuration(DATA.DEFAULT_BatchParams.startTime, 0));
        set(GUI.batch_endTime, 'String', calcDuration(DATA.DEFAULT_BatchParams.endTime, 1));
        set(GUI.batch_windowLength, 'String', calcDuration(DATA.DEFAULT_BatchParams.windowLength, 0));
        set(GUI.batch_overlap, 'String', num2str(DATA.DEFAULT_BatchParams.overlap));
        set(GUI.batch_winNum, 'String', num2str(DATA.DEFAULT_BatchParams.winNum));
        
        DATA.BatchParams = DATA.DEFAULT_BatchParams;
    end
%% Open the window
    function GUI = createInterface()
        
        SmallFontSize = DATA.SmallFontSize;
        BigFontSize = DATA.BigFontSize;
        
        %params_uicontrols = DATA.params_uicontrols;
        
        %iconpath = [matlabroot, '/toolbox/matlab/icons/'];
        
        % Create the user interface for the application and return a
        % structure of handles for global use.
        GUI = struct();
        % Open a new figure window and remove the toolbar and menus
        % Open a window and add some menus
        %GUI.SaveFiguresWindow = [];
        GUI.Window = figure( ...
            'Name', 'PhysioZoo', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [20, 50, DATA.window_size(1), DATA.window_size(2)], ...
            'Tag', 'fPhysioZoo');
        
        %         import java.awt.*
        %         import javax.swing.*
        %         %figIcon = ImageIcon([iconpath 'tool_legend.gif']);
        %         figIcon = ImageIcon([iconpath 'greenarrowicon.gif']);
        %         %figIcon = ImageIcon([iconpath 'Arwen4.gif']);
        %         drawnow;
        %         mde = com.mathworks.mde.desk.MLDesktop.getInstance;
        %         jTreeFig = mde.getClient('HRV Analysis').getTopLevelAncestor;
        %         jTreeFig.setIcon(figIcon);
        
        
        DATA.zoom_handle = zoom(GUI.Window);
        DATA.zoom_handle.Motion = 'vertical';
        DATA.zoom_handle.Enable = 'on';
        
        % + File menu
        GUI.FileMenu = uimenu( GUI.Window, 'Label', 'File' );
        uimenu( GUI.FileMenu, 'Label', 'Open File', 'Callback', @onOpenFile, 'Accelerator','O');
        GUI.DataQualityMenu = uimenu( GUI.FileMenu, 'Label', 'Open Data Quality File', 'Callback', @onOpenDataQualityFile, 'Accelerator','Q', 'Enable', 'off');
        GUI.LoadConfigFile = uimenu( GUI.FileMenu, 'Label', 'Load Custom Config File', 'Callback', @onLoadCustomConfigFile, 'Accelerator','P', 'Enable', 'off');
        GUI.SaveAsMenu = uimenu( GUI.FileMenu, 'Label', 'Save HRV Measures as', 'Callback', @onSaveResultsAsFile, 'Accelerator','S', 'Enable', 'off');
        GUI.SaveFiguresAsMenu = uimenu( GUI.FileMenu, 'Label', 'Export Figures', 'Callback', @onSaveFiguresAsFile, 'Accelerator','F', 'Enable', 'off');
        GUI.SaveParamFileMenu = uimenu( GUI.FileMenu, 'Label', 'Save Config File', 'Callback', @onSaveParamFile, 'Accelerator','P', 'Enable', 'off');
        uimenu( GUI.FileMenu, 'Label', 'Exit', 'Callback', @onExit, 'Separator', 'on', 'Accelerator', 'E');
        
        % + Help menu
        helpMenu = uimenu( GUI.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        uimenu( helpMenu, 'Label', 'PhysioZoo Home', 'Callback', @onPhysioZooHome );
        %uimenu( helpMenu, 'Label', 'About', 'Callback', @onAbout );
        
        % Create the layout (Arrange the main interface)
        GUI.mainLayout = uix.VBoxFlex('Parent', GUI.Window, 'Spacing', 3);
        
        % + Create the panels
        GUI.RawData_Box = uix.HBoxFlex('Parent', GUI.mainLayout, 'Spacing', 5); % Upper Part
        GUI.Statistics_BoxPanel = uix.BoxPanel( 'Parent', GUI.mainLayout, 'Title', '  ', 'Padding', 5 ); %Low Part
        
        raw_data_part = 0.5;
        statistics_part = 1 - raw_data_part;
        set( GUI.mainLayout, 'Heights', [(-1)*raw_data_part, (-1)*statistics_part]  );
        
        %---------------------------------
        GUI.Statistics_Box = uix.HBoxFlex('Parent', GUI.Statistics_BoxPanel, 'Spacing', 3);
        GUI.Analysis_TabPanel = uix.TabPanel('Parent', GUI.Statistics_Box, 'Padding', 0');
        
        options_part = 0.25; % 0.27
        analysis_part = 1 - options_part;
        Left_Part_widths_in_pixels = options_part*(DATA.window_size(1));
        %---------------------------------
        GUI.StatisticshTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', 5);
        GUI.TimeTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', 5);
        GUI.FrequencyTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', 5);
        GUI.NonLinearTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', 5);
        
        temp_panel = uix.Panel( 'Parent', GUI.RawData_Box, 'Padding', 5);
        GUI.Options_TabPanel = uix.TabPanel('Parent', temp_panel, 'Padding', 0');
        
        temp_panel = uix.Panel( 'Parent', GUI.RawData_Box, 'Padding', 5);
        GUI.RawDataControls_Box = uix.VBox('Parent', temp_panel, 'Spacing', 3);
        set( GUI.RawData_Box, 'Widths', [(-1)*options_part (-1)*analysis_part] ); % [-22 -75]
        
        buttons_axes_Box = uix.HBox( 'Parent', GUI.RawDataControls_Box, 'Spacing', 5);
        
        GUI.CommandsButtons_Box = uix.VButtonBox('Parent', buttons_axes_Box, 'Spacing', 3, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
        
        GUI.RawDataAxes = axes('Parent', uicontainer('Parent', buttons_axes_Box) );
        set( buttons_axes_Box, 'Widths', [70 -1]);
        GUI.WindowSliderBox = uix.HBox('Parent', GUI.RawDataControls_Box, 'Spacing', 3);
        GUI.Filt_WindowSliderBox = uix.HBox('Parent', GUI.RawDataControls_Box, 'Spacing', 3);
        set( GUI.RawDataControls_Box, 'Heights', [-1, 22, 22]  );
        
        %--------------------------
        
        field_size = [170 -5 -5 170 -5 -5 -30]; %[155 -5 -5 155 -5 -5 -70];
        uicontrol( 'Style', 'text', 'Parent', GUI.WindowSliderBox, 'String', 'Window start:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.FirstSecond = uicontrol( 'Style', 'edit', 'Parent', GUI.WindowSliderBox, 'Callback', @FirstSecond_Callback, 'FontSize', BigFontSize, 'Enable', 'off');
        uicontrol( 'Style', 'text', 'Parent', GUI.WindowSliderBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        uicontrol( 'Style', 'text', 'Parent', GUI.WindowSliderBox, 'String', 'Window size:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.WindowSize = uicontrol( 'Style', 'edit', 'Parent', GUI.WindowSliderBox, 'Callback', @WindowSize_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', GUI.WindowSliderBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        GUI.RawDataSlider = uicontrol( 'Style', 'slider', 'Parent', GUI.WindowSliderBox, 'Callback', @slider_Callback);
        GUI.RawDataSlider.Enable = 'off';
        addlistener(GUI.RawDataSlider, 'ContinuousValueChange', @sldrFrame_Motion);
        set( GUI.WindowSliderBox, 'Widths', field_size );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.Filt_WindowSliderBox, 'String', 'Selected window start:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.Filt_FirstSecond = uicontrol( 'Style', 'edit', 'Parent', GUI.Filt_WindowSliderBox, 'Callback', @Filt_FirstSecond_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', GUI.Filt_WindowSliderBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        uicontrol( 'Style', 'text', 'Parent', GUI.Filt_WindowSliderBox, 'String', 'Selected window size:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.Filt_WindowSize = uicontrol( 'Style', 'edit', 'Parent', GUI.Filt_WindowSliderBox, 'Callback', @Filt_WindowSize_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', GUI.Filt_WindowSliderBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        GUI.Filt_RawDataSlider = uicontrol( 'Style', 'slider', 'Parent', GUI.Filt_WindowSliderBox, 'Callback', @filt_slider_Callback, 'Enable', 'off');
        %GUI.Filt_RawDataSlider.Enable = 'off';
        addlistener(GUI.Filt_RawDataSlider, 'ContinuousValueChange', @filt_sldrFrame_Motion);
        set( GUI.Filt_WindowSliderBox, 'Widths', field_size );
        
        GUI.RR_or_HR_plot_button = uicontrol( 'Style', 'ToggleButton', 'Parent', GUI.CommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', GUI.CommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        set( GUI.CommandsButtons_Box, 'ButtonSize', [70, 25], 'Spacing', 5  );
        
        GUI.OptionsTab = uix.Panel( 'Parent', GUI.Options_TabPanel, 'Padding', 5);
        GUI.AdvancedTab = uix.Panel( 'Parent', GUI.Options_TabPanel, 'Padding', 5);
        GUI.BatchTab = uix.Panel( 'Parent', GUI.Options_TabPanel, 'Padding', 5);
        
        tabs_widths = Left_Part_widths_in_pixels; %342 310;
        tabs_heights = 370;
        
        GUI.OptionsSclPanel = uix.ScrollingPanel( 'Parent', GUI.OptionsTab);
        GUI.OptionsBox = uix.VBox( 'Parent', GUI.OptionsSclPanel, 'Spacing', 5);
        set( GUI.OptionsSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.BatchSclPanel = uix.ScrollingPanel( 'Parent', GUI.BatchTab);
        GUI.BatchBox = uix.VBox( 'Parent', GUI.BatchSclPanel, 'Spacing', 5);
        set( GUI.BatchSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        %--------------------------------------------------------------------------------------------
        GUI.AdvancedBox = uix.VBox( 'Parent', GUI.AdvancedTab, 'Spacing', 5);
        GUI.Advanced_TabPanel = uix.TabPanel('Parent', GUI.AdvancedBox, 'Padding', 0');
        
        GUI.FilteringParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', 5);
        GUI.TimeParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', 5);
        GUI.FrequencyParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', 5);
        GUI.NonLinearParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', 5);
        
        GUI.FilteringSclPanel = uix.ScrollingPanel('Parent', GUI.FilteringParamTab);
        GUI.FilteringParamBox = uix.VBox('Parent', GUI.FilteringSclPanel, 'Spacing', 7);
        set( GUI.FilteringSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.TimeSclPanel = uix.ScrollingPanel('Parent', GUI.TimeParamTab);
        GUI.TimeParamBox = uix.VBox('Parent', GUI.TimeSclPanel, 'Spacing', 7);
        set( GUI.TimeSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.FrequencySclPanel = uix.ScrollingPanel('Parent', GUI.FrequencyParamTab);
        GUI.FrequencyParamBox = uix.VBox('Parent', GUI.FrequencySclPanel, 'Spacing', 7);
        set( GUI.FrequencySclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.NonLinearParamSclPanel = uix.ScrollingPanel('Parent', GUI.NonLinearParamTab);
        GUI.NonLinearParamBox = uix.VBox('Parent', GUI.NonLinearParamSclPanel, 'Spacing', 7);
        set( GUI.NonLinearParamSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        %------------------------------------------------------------------------------
        
        field_size = [170, -1, 1]; % [-37, -40, -15]
        
        GUI.RecordNameBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', GUI.RecordNameBox, 'String', 'Record file name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.RecordName_text = uicontrol( 'Style', 'text', 'Parent', GUI.RecordNameBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', GUI.RecordNameBox );
        set( GUI.RecordNameBox, 'Widths', field_size  );
        
        GUI.DataQualityBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', GUI.DataQualityBox, 'String', 'Data quality file name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.DataQuality_text = uicontrol( 'Style', 'text', 'Parent', GUI.DataQualityBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', GUI.DataQualityBox );
        set( GUI.DataQualityBox, 'Widths', field_size );
        
        GUI.DataLengthBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'String', 'Record length', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.RecordLength_text = uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'String', 'h:min:sec');
        uix.Empty( 'Parent', GUI.DataLengthBox );
        set( GUI.DataLengthBox, 'Widths', field_size );
        
        field_size = [170, 140, -1]; % [180, -1, 300]
        GUI.MammalBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', GUI.MammalBox, 'String', 'Mammal', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Mammal_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.MammalBox, 'Callback', @Mammal_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', DATA.GUI_mammals);
        %GUI.Mammal_popupmenu.String = DATA.GUI_mammals;
        uix.Empty( 'Parent', GUI.MammalBox );
        set( GUI.MammalBox, 'Widths', field_size );
        
        GUI.IntegrationBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', GUI.IntegrationBox, 'String', 'Integration Level', 'FontSize', SmallFontSize, 'Enable', 'off', 'HorizontalAlignment', 'left');
        GUI.Integration_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.IntegrationBox, 'Callback', @Integration_popupmenu_Callback, 'FontSize', SmallFontSize, 'Enable', 'off');
        GUI.Integration_popupmenu.String = DATA.GUI_Integration;
        uix.Empty( 'Parent', GUI.IntegrationBox );
        set( GUI.IntegrationBox, 'Widths', field_size );
        
        GUI.FilteringBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringBox, 'String', 'Filtering', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Filtering_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.FilteringBox, 'Callback', @Filtering_popupmenu_Callback, 'FontSize', SmallFontSize);
        GUI.Filtering_popupmenu.String = DATA.Filters;
        uix.Empty( 'Parent', GUI.FilteringBox );
        set( GUI.FilteringBox, 'Widths', field_size );
        
        DefaultMethodBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', DefaultMethodBox, 'String', 'Default frequency method', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.DefaultMethod_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', DefaultMethodBox, 'Callback', @DefaultMethod_popupmenu_Callback, 'FontSize', SmallFontSize, 'TooltipString', 'Default frequency method to use to display under statistics');
        GUI.DefaultMethod_popupmenu.String = DATA.methods;
        GUI.DefaultMethod_popupmenu.Value = 2;
        uix.Empty( 'Parent', DefaultMethodBox );
        set( DefaultMethodBox, 'Widths', field_size );
        
        GUI.YLimitBox = uix.HBox('Parent', GUI.OptionsBox, 'Spacing', 3);
        
        uicontrol( 'Style', 'text', 'Parent', GUI.YLimitBox, 'String', 'Y Limit:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.MinYLimit_Edit = uicontrol( 'Style', 'edit', 'Parent', GUI.YLimitBox, 'Callback', @MinYLimit_Edit_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', GUI.YLimitBox, 'String', '-', 'FontSize', BigFontSize);
        GUI.MaxYLimit_Edit = uicontrol( 'Style', 'edit', 'Parent', GUI.YLimitBox, 'Callback', @MaxYLimit_Edit_Callback, 'FontSize', BigFontSize);
        uix.Empty( 'Parent', GUI.YLimitBox );
        set( GUI.YLimitBox, 'Widths', [170, 67, 5, 65 -1]  ); %[140, -17, -5, -17 100] [-37, -17, -5, -16 -16] [-37, -20, -5, -19 -16] [-37, -15, -5, -15] [-37, -20, -5, -19 -15]
        
        uix.Empty( 'Parent', GUI.OptionsBox );
        set( GUI.OptionsBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 24 -7] );
        %---------------------------
        
        uix.Empty( 'Parent', GUI.BatchBox );
        
        field_size = [150, 120, -1];
        
        BatchStartTimeBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', BatchStartTimeBox, 'String', 'Selected window start', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.batch_startTime = uicontrol( 'Style', 'edit', 'Parent', BatchStartTimeBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'startTime');        % , 'String', DATA.DEFAULT_BatchParams.startTime
        uicontrol( 'Style', 'text', 'Parent', BatchStartTimeBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        set( BatchStartTimeBox, 'Widths', field_size  );
        
        BatchEndTimeBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', BatchEndTimeBox, 'String', 'Selected window end', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.batch_endTime = uicontrol( 'Style', 'edit', 'Parent', BatchEndTimeBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'endTime');       % , 'String', DATA.DEFAULT_BatchParams.endTime
        uicontrol( 'Style', 'text', 'Parent', BatchEndTimeBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        set( BatchEndTimeBox, 'Widths', field_size );
        
        BatchWindowLengthBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', BatchWindowLengthBox, 'String', 'Selected window size', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.batch_windowLength = uicontrol( 'Style', 'edit', 'Parent', BatchWindowLengthBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'windowLength');       % , 'String', DATA.DEFAULT_BatchParams.windowLength
        uicontrol( 'Style', 'text', 'Parent', BatchWindowLengthBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        set( BatchWindowLengthBox, 'Widths', field_size  );
        
        BatchOverlapBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', BatchOverlapBox, 'String', 'Overlap', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.batch_overlap = uicontrol( 'Style', 'edit', 'Parent', BatchOverlapBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'overlap');        % , 'String', DATA.DEFAULT_BatchParams.overlap
        uicontrol( 'Style', 'text', 'Parent', BatchOverlapBox, 'String', '%', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        set( BatchOverlapBox, 'Widths', field_size  );
        
        BatchWinNumBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', BatchWinNumBox, 'String', 'Windows number', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.batch_winNum = uicontrol( 'Style', 'edit', 'Parent', BatchWinNumBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'winNum', 'Enable', 'inactive');      % , 'String', DATA.DEFAULT_BatchParams.winNum
        uix.Empty( 'Parent', BatchWinNumBox );
        set( BatchWinNumBox, 'Widths', field_size );
        
        uix.Empty( 'Parent', GUI.BatchBox );
        
        batch_Box = uix.HBox('Parent', GUI.BatchBox, 'Spacing', 5);
        uix.Empty( 'Parent', batch_Box );
        uicontrol( 'Style', 'PushButton', 'Parent', batch_Box, 'Callback', @RunMultSegments_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Run');
        uix.Empty( 'Parent', batch_Box );
        set( batch_Box, 'Widths', [250 125 -1] );
        
        uix.Empty( 'Parent', GUI.BatchBox );
        set( GUI.BatchBox, 'Heights', [-10 -10 -10 -10 -10 -10  -20 -15 -60] );
        %---------------------------
        tables_field_size = [-85 -15];
        
        GUI.TimeBox = uix.HBox( 'Parent', GUI.TimeTab, 'Spacing', 5);
        GUI.ParamTimeBox = uix.VBox( 'Parent', GUI.TimeBox, 'Spacing', 5);
        GUI.TimeParametersTable = uitable( 'Parent', GUI.ParamTimeBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.TimeParametersTable.ColumnName = {'    Measures Name    ', 'Values'};
        uix.Empty( 'Parent', GUI.ParamTimeBox );
        set( GUI.ParamTimeBox, 'Heights', tables_field_size );
        
        GUI.TimeAxes1 = axes('Parent', uicontainer('Parent', GUI.TimeBox) );
        set( GUI.TimeBox, 'Widths', [-14 -80] );  % [-11 -90]
        %---------------------------
        
        GUI.FrequencyBox = uix.HBox( 'Parent', GUI.FrequencyTab, 'Spacing', 5);
        GUI.ParamFrequencyBox = uix.VBox( 'Parent', GUI.FrequencyBox, 'Spacing', 5);
        GUI.FrequencyParametersTable = uitable( 'Parent', GUI.ParamFrequencyBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.FrequencyParametersTable.ColumnName = {'                Measures Name                ', 'Values Lomb', 'Values Welch', 'Values AR'};
        uix.Empty( 'Parent', GUI.ParamFrequencyBox );
        set( GUI.ParamFrequencyBox, 'Heights', tables_field_size );
        
        PSD_Box = uix.VBox( 'Parent', GUI.FrequencyBox, 'Spacing', 5);
        PSD_HBox = uix.HBox('Parent', PSD_Box, 'Spacing', 3);  % , 'VerticalAlignment', 'top'
        FrAxesBox = uix.HBox( 'Parent', PSD_Box, 'Spacing', 1);
        
        %         Gain_ButtonsBox = uix.VButtonBox( 'Parent', FrAxesBox);
        %         uicontrol( 'Style', 'PushButton', 'Parent', Gain_ButtonsBox, 'Callback', @up_pushbutton_Callback, 'FontSize', BigFontSize, 'String', char(9650)); % , 'FontName','Blue Highway'
        %         uicontrol( 'Style', 'PushButton', 'Parent', Gain_ButtonsBox, 'Callback', @down_pushbutton_Callback, 'FontSize', BigFontSize, 'String', char(9660));
        %         uix.Empty( 'Parent', Gain_ButtonsBox );
        %         set( Gain_ButtonsBox, 'ButtonSize', [25 25], 'Spacing', 1, 'Padding', 1, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom' );
        
        GUI.FrequencyAxes1 = axes('Parent', uicontainer('Parent', FrAxesBox) );
        GUI.FrequencyAxes2 = axes('Parent', uicontainer('Parent', FrAxesBox) );
        
        set( PSD_Box, 'Heights', [-7 -93] );
        set( FrAxesBox, 'Widths', [-50 -50], 'Padding', 1 );
        
        uix.Empty( 'Parent', PSD_HBox );
        GUI.freq_yscale_Button = uicontrol( 'Style', 'ToggleButton', 'Parent', PSD_HBox, 'Callback', @PSD_pushbutton_Callback, 'FontSize', BigFontSize, 'Value', 1, 'String', 'Log');
        uix.Empty( 'Parent', PSD_HBox );
        set( PSD_HBox, 'Widths', [-30 100 -45] );
        
        set( GUI.FrequencyBox, 'Widths', [-34 -64] );   % [-34 -64] [-34 -32 -32]
        %---------------------------
        
        GUI.NonLinearBox = uix.HBox( 'Parent', GUI.NonLinearTab, 'Spacing', 5);
        GUI.ParamNonLinearBox = uix.VBox( 'Parent', GUI.NonLinearBox, 'Spacing', 5);
        GUI.NonLinearTable = uitable( 'Parent', GUI.ParamNonLinearBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.NonLinearTable.ColumnName = {'    Measures Name    ', 'Values'};
        uix.Empty( 'Parent', GUI.ParamNonLinearBox );
        set( GUI.ParamNonLinearBox, 'Heights', tables_field_size );
        
        GUI.NonLinearAxes1 = axes('Parent', uicontainer('Parent', GUI.NonLinearBox) );
        GUI.NonLinearAxes2 = axes('Parent', uicontainer('Parent', GUI.NonLinearBox) );
        GUI.NonLinearAxes3 = axes('Parent', uicontainer('Parent', GUI.NonLinearBox) );
        set( GUI.NonLinearBox, 'Widths', [-14 -24 -24 -24] );        % [-9 -25 -25 -25]
        %---------------------------
        GUI.StatisticsTable = uitable( 'Parent', GUI.StatisticshTab, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');    % 700
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
        %---------------------------
        
        GUI.Advanced_TabPanel.TabTitles = {'Filtering', 'Time', 'Frequency', 'NonLinear'};
        GUI.Advanced_TabPanel.TabWidth = 65; %(Left_Part_widths_in_pixels - 60)/4; %65;
        GUI.Advanced_TabPanel.FontSize = SmallFontSize-2;
        
        GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'Time', 'Frequency', 'NonLinear'};
        GUI.Analysis_TabPanel.TabWidth = 90;
        GUI.Analysis_TabPanel.FontSize = BigFontSize;
        
        GUI.Options_TabPanel.TabTitles = {'Records', 'Options', 'Batch'};
        GUI.Options_TabPanel.TabWidth = 90;
        GUI.Options_TabPanel.FontSize = BigFontSize;
    end % createInterface

%%
    function clearParametersBox(VBoxHandle)
        param_boxes_handles = allchild(VBoxHandle);
        if ~isempty(param_boxes_handles)
            delete(param_boxes_handles);
        end
    end
%%
    function param_keys_length = FillParamFields(VBoxHandle, param_map)
        
        SmallFontSize = DATA.SmallFontSize;
        
        param_keys = keys(param_map);
        param_keys_length = length(param_keys);
        
        for i = 1 : param_keys_length
            
            HBox = uix.HBox( 'Parent', VBoxHandle, 'Spacing', 3);
            
            field_name = param_keys{i};
            
            current_field = param_map(field_name);
            current_field_value = current_field.value;
            
            uicontrol( 'Style', 'text', 'Parent', HBox, 'String', current_field.name, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
            
            fields_size = [150, 125, -1]; %[125, -1, 90] [-40, -27, -25]
            %             if ischar(current_field_value)
            %                 PopUpMenu_control = uicontrol( 'Style', 'PopUpMenu', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
            %                 PopUpMenu_control.String = DATA.methods;
            %                 DATA.default_method_index = find(cellfun(@(x) strcmpi(x, current_field_value),DATA.methods ));
            %                 set(PopUpMenu_control, 'Value', DATA.default_method_index);
            %                 uix.Empty( 'Parent', HBox );
            %                 set( HBox, 'Widths', fields_size  );
            % else
            if length(current_field_value) < 2
                current_value = num2str(current_field_value);
                param_control = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
                set(param_control, 'String', current_value, 'UserData', current_value);
            else
                field_name_min = [field_name '.min'];
                current_value = num2str(current_field_value(1));
                param_control = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name_min}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_min);
                set(param_control, 'String', current_value, 'UserData', current_value);
                uicontrol( 'Style', 'text', 'Parent', HBox, 'String', '-', 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
                field_name_max = [field_name '.max'];
                current_value = num2str(current_field_value(2));
                param_control = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name_max}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_max);
                set(param_control, 'String', current_value, 'UserData', current_value);
            end
            uicontrol( 'Style', 'text', 'Parent', HBox, 'String', current_field.units, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
            
            if length(current_field_value) < 2
                %set( HBox, 'Widths', [-67, -40, -33]  );
                set( HBox, 'Widths', fields_size  );
            else
                %set( HBox, 'Widths', [-67, -18, -2, -18, -33]  );
                set( HBox, 'Widths', [150, 58, 5, 56, -1]  );%[125, -12, -2, -12, 90] [-40, -12, -2, -12, -25] %  [-30, -8, -2, -8, -10]
            end
            %end
        end
    end

%%
    function createConfigParametersInterface()
        
        gui_param = ReadYaml('gui_params.yml');
        gui_param_names = fieldnames(gui_param);
        param_struct = gui_param.(gui_param_names{1});
        param_name = fieldnames(param_struct);
        not_in_use_params_fr = param_struct.(param_name{1});
        %not_in_use_params_nl = param_struct.(param_name{2});
        not_in_use_params_mse = param_struct.(param_name{2});
        
        SmallFontSize = DATA.SmallFontSize;
        
        defaults_map = rhrv_get_all_defaults();
        param_keys = keys(defaults_map);
        
        filtrr_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'filtrr')), param_keys)));
        filt_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.range')), filtrr_keys)));
        lowpass_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.lowpass')), filtrr_keys)));
        quotient_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.quotient')), filtrr_keys)));
        
        filt_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_range_keys))) = [];
        lowpass_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), lowpass_range_keys))) = [];
        quotient_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), quotient_range_keys))) = [];
        
        DATA.filter_quotient = rhrv_get_default('filtrr.quotient.enable', 'value');
        DATA.filter_lowpass = rhrv_get_default('filtrr.lowpass.enable', 'value');
        DATA.filter_range = rhrv_get_default('filtrr.range.enable', 'value');
        
        if DATA.filter_quotient && DATA.filter_lowpass && DATA.filter_range
            DATA.filter_index = 4;
        elseif ~DATA.filter_quotient && ~DATA.filter_lowpass && ~DATA.filter_range
            DATA.filter_index = 5;
        elseif DATA.filter_lowpass
            DATA.filter_index = 1;
        elseif DATA.filter_range
            DATA.filter_index = 2;
        elseif DATA.filter_quotient
            DATA.filter_index = 3;
        end
        GUI.Filtering_popupmenu.Value = DATA.filter_index;
        
        hrv_time_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'hrv_time')), param_keys)));
        hrv_freq_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'hrv_freq')), param_keys)));
        %hrv_nl_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'hrv_nl')), param_keys)));
        dfa_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'dfa')), param_keys)));
        mse_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'mse')), param_keys)));
        
        for i = 1 : length(not_in_use_params_fr)
            hrv_freq_keys(find(cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_fr{i})), hrv_freq_keys))) = [];
        end
        for i = 1 : length(not_in_use_params_mse)
            mse_keys(find(cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_mse{i})), mse_keys))) = [];
        end
        %         for i = 1 : length(not_in_use_params_nl)
        %             hrv_nl_keys(find(cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_nl{i})), hrv_nl_keys))) = [];
        %         end
        
        
        % Filtering Parameters
        clearParametersBox(GUI.FilteringParamBox);
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Range', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        filt_range_keys_length = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_range_keys, values(defaults_map, filt_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Lowpass', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        filt_lowpass_keys_length = FillParamFields(GUI.FilteringParamBox, containers.Map(lowpass_range_keys, values(defaults_map, lowpass_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Quotient', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        filt_quotient_keys_length = FillParamFields(GUI.FilteringParamBox, containers.Map(quotient_range_keys, values(defaults_map, quotient_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        rs = 19; %-22;
        ts = 19; % -18
        es = 2;
        set( GUI.FilteringParamBox, 'Height', [ts, rs * ones(1, filt_range_keys_length), es, ts,  rs * ones(1, filt_lowpass_keys_length), es, ts,  rs * ones(1, filt_quotient_keys_length), -20]  );
        
        % Time Parameters
        clearParametersBox(GUI.TimeParamBox);
        uix.Empty( 'Parent', GUI.TimeParamBox );
        time_keys_length = FillParamFields(GUI.TimeParamBox, containers.Map(hrv_time_keys, values(defaults_map, hrv_time_keys)));
        uix.Empty( 'Parent', GUI.TimeParamBox );
        rs = 19; %-10;
        ts = 19;
        set( GUI.TimeParamBox, 'Height', [ts, rs * ones(1, time_keys_length), -167]  );
        
        %-----------------------------------
        
        % Frequency Parameters
        clearParametersBox(GUI.FrequencyParamBox);
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        freq_param_length = FillParamFields(GUI.FrequencyParamBox, containers.Map(hrv_freq_keys, values(defaults_map, hrv_freq_keys)));
        
        
        % NonLinear Parameters - Beta
        %uix.Empty( 'Parent', GUI.FrequencyParamBox );
        %nl_param_length = FillParamFields(GUI.FrequencyParamBox, containers.Map(hrv_nl_keys, values(defaults_map, hrv_nl_keys)));
        
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        rs = 19; %19;
        %set( GUI.FrequencyParamBox, 'Height', [-10, rs * ones(1, freq_param_length), -10, rs, -17, -50]  );
        set( GUI.FrequencyParamBox, 'Height', [-10, rs * ones(1, freq_param_length), -50]  );
        
        %-----------------------------------
        
        % NonLinear Parameters - DFA
        clearParametersBox(GUI.NonLinearParamBox);
        uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Detrended Fluctuation Analysis (DFA)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        dfa_param_length = FillParamFields(GUI.NonLinearParamBox, containers.Map(dfa_keys, values(defaults_map, dfa_keys)));
        
        % NonLinear Parameters - MSE
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Multi Scale Entropy (MSE)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        mse_param_length = FillParamFields(GUI.NonLinearParamBox, containers.Map(mse_keys, values(defaults_map, mse_keys)));
        
        %         % NonLinear Parameters - Beta
        %         uix.Empty( 'Parent', GUI.NonLinearParamBox );
        %         FillParamFields(GUI.NonLinearParamBox, containers.Map(hrv_nl_keys, values(defaults_map, hrv_nl_keys)));
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        
        rs = 19; %-22;
        ts = 19; % -18
        es = 2; % -15
        %set( GUI.NonLinearParamBox, 'Heights', [ts, rs * ones(1, dfa_param_length), es, ts,  rs * ones(1, mse_param_length), ts/2, rs, -35] );
        set( GUI.NonLinearParamBox, 'Heights', [ts, rs * ones(1, dfa_param_length), es, ts,  rs * ones(1, mse_param_length), -25] );
    end

%set( GUI.NonLinearParamBox, 'Widths', 600, 'Heights', 600, 'HorizontalOffsets', 100, 'VerticalOffsets', 100 )
%%
    function slider_Callback(~, ~)
        %firstSecond2Show = int64(get(GUI.RawDataSlider, 'Value'));
        firstSecond2Show = get(GUI.RawDataSlider, 'Value');
        DATA.firstSecond2Show = get(GUI.RawDataSlider, 'Value');
        set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
        %GetPlotSignal();
        %plotRawData();
        setXAxesLim();
    end

%%
    function sldrFrame_Motion(~, ~)
        %firstSecond2Show = int64(get(GUI.RawDataSlider, 'Value'));
        %firstSecond2Show = get(GUI.RawDataSlider, 'Value');
        DATA.firstSecond2Show = get(GUI.RawDataSlider, 'Value');
        set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
        %GetPlotSignal();
        %plotRawData();
        setXAxesLim();
    end

%%
    function filt_slider_Callback(~, ~)
        
        %Filt_FirstSecond2Show = get(GUI.Filt_RawDataSlider, 'Value');
        
        DATA.BatchParams.startTime = get(GUI.Filt_RawDataSlider, 'Value');
        DATA.BatchParams.endTime = DATA.BatchParams.startTime + DATA.BatchParams.windowLength;
        
        str = calcDuration(DATA.BatchParams.startTime, 0);
        set(GUI.Filt_FirstSecond, 'String', str);
        set(GUI.batch_startTime, 'String', str);
        set(GUI.batch_endTime, 'String', calcDuration(DATA.BatchParams.endTime, 0));
        
        clear_statistics_plots();
        clearStatTables();
        calcBatchWinNum();
        plotFilteredData();
        plotMultipleWindows();
        calcStatistics();        
    end
%%
    function filt_sldrFrame_Motion(~, ~)        
        %Filt_FirstSecond2Show = get(GUI.Filt_RawDataSlider, 'Value');
        
        DATA.BatchParams.startTime = get(GUI.Filt_RawDataSlider, 'Value');
        str = calcDuration(DATA.BatchParams.startTime, 0);
        set(GUI.Filt_FirstSecond, 'String', str);
        set(GUI.batch_startTime, 'String', str);
        
        plotFilteredData();        
        plotMultipleWindows();        
    end
%%
    function setYAxesLim()
        ha = GUI.RawDataAxes;
        
        if (DATA.PlotHR == 0)
            MinYLimit = min(DATA.RRMinYLimit, DATA.RRMaxYLimit);
            MaxYLimit = max(DATA.RRMinYLimit, DATA.RRMaxYLimit);
            
            Filt_MinYLimit = min(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
            Filt_MaxYLimit = max(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
        else
            MinYLimit = min(DATA.HRMinYLimit, DATA.HRMaxYLimit);
            MaxYLimit = max(DATA.HRMinYLimit, DATA.HRMaxYLimit);
            
            Filt_MinYLimit = min(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
            Filt_MaxYLimit = max(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
        end
        
        DATA.MaxYLimit = MaxYLimit;
        DATA.MinYLimit = MinYLimit;
        
        set(ha, 'YLim', [MinYLimit MaxYLimit]);
    end
%%
    function setXAxesLim()
        ha = GUI.RawDataAxes;
        
        win_indexes = find(DATA.trr >= DATA.firstSecond2Show & DATA.trr <= DATA.firstSecond2Show + DATA.MyWindowSize);
        
        signal_time = DATA.trr(win_indexes(1) : win_indexes(end));
        %signal_data = DATA.rri(win_indexes(1) : win_indexes(end));
        
        set(ha, 'XLim', [signal_time(1) signal_time(end)]);
        
        x_ticks_array = get(ha, 'XTick');
        set(ha, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0), x_ticks_array, 'UniformOutput', false));
    end
%%
    function plotRawData()
        ha = GUI.RawDataAxes;
        
        %time_data = DATA.trr;
        %data = DATA.rri;
        
        Filt_time_data = DATA.tnn;
        Filt_data = DATA.nni;
        filt_win_indexes = find(Filt_time_data >= DATA.firstSecond2Show & Filt_time_data <= DATA.firstSecond2Show + DATA.MyWindowSize);
        filt_signal_time = Filt_time_data(filt_win_indexes(1) : filt_win_indexes(end));
        filt_signal_data = Filt_data(filt_win_indexes(1) : filt_win_indexes(end));
        if (DATA.PlotHR == 0)
            filt_data =  filt_signal_data;
        else
            filt_data =  60 ./ filt_signal_data;
        end
        
        
        win_indexes = find(DATA.trr >= DATA.firstSecond2Show & DATA.trr <= DATA.firstSecond2Show + DATA.MyWindowSize);
        
        signal_time = DATA.trr(win_indexes(1) : win_indexes(end));
        signal_data = DATA.rri(win_indexes(1) : win_indexes(end));
        
        if (DATA.PlotHR == 0)
            data =  signal_data;
            yString = 'RR (sec)';
            %             MinYLimit = min(DATA.RRMinYLimit, DATA.RRMaxYLimit);
            %             MaxYLimit = max(DATA.RRMinYLimit, DATA.RRMaxYLimit);
            %
            %             Filt_MinYLimit = min(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
            %             Filt_MaxYLimit = max(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
        else
            data =  60 ./ signal_data;
            yString = 'HR (BPM)';
            %             MinYLimit = min(DATA.HRMinYLimit, DATA.HRMaxYLimit);
            %             MaxYLimit = max(DATA.HRMinYLimit, DATA.HRMaxYLimit);
            %
            %             Filt_MinYLimit = min(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
            %             Filt_MaxYLimit = max(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
        end
        
        %         DATA.MaxYLimit = MaxYLimit;
        %         DATA.MinYLimit = MinYLimit;
        %
        GUI.raw_data_handle = plot(ha, signal_time, data, 'b-', 'LineWidth', 2);
        hold(ha, 'on');
        
        
        
        %GUI.filtered_handle = plot(ha, filt_signal_time, filt_data, 'g-', 'LineWidth', 1);        
        GUI.filtered_handle = line(ha, filt_signal_time, filt_data, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-');        
        
        
        %set(ha, 'XLim', [signal_time(1) signal_time(end)]);
        %set(ha, 'YLim', [MinYLimit MaxYLimit]);
        xlabel(ha, 'Time (sec)');
        ylabel(ha, yString);
        
        %x_ticks_array = get(ha, 'XTick');
        %set(ha, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0), x_ticks_array, 'UniformOutput', false));
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.RawDataAxes, false);
    end
%%
    function plotFilteredData()
        ha = GUI.RawDataAxes;
        
        Filt_time_data = DATA.tnn;
        Filt_data = DATA.nni;
        
        %filt_win_indexes = find(Filt_time_data >= DATA.BatchParams.startTime & Filt_time_data <= DATA.BatchParams.endTime);        % DATA.Filt_MyWindowSize
        filt_win_indexes = find(Filt_time_data >= DATA.BatchParams.startTime & Filt_time_data <= DATA.BatchParams.effectiveEndTime);
        
        if ~isempty(filt_win_indexes)
            
%             if isfield(GUI, 'filtered_handle')
%                 delete(GUI.filtered_handle);
%             end
            
            filt_signal_time = Filt_time_data(filt_win_indexes(1) : filt_win_indexes(end));
            filt_signal_data = Filt_data(filt_win_indexes(1) : filt_win_indexes(end));
            
            if (DATA.PlotHR == 0)
                filt_data =  filt_signal_data;
            else
                filt_data =  60 ./ filt_signal_data;
            end
            %GUI.filtered_handle = plot(ha, filt_signal_time, filt_data, 'g-', 'LineWidth', 1);
            filt_data_vector = ones(1, length(DATA.nni))*NaN;
            filt_data_vector(filt_win_indexes) = filt_data;
            GUI.filtered_handle.YData = filt_data_vector;
            %line(ha, filt_signal_time, filt_data, 'LineWidth', 1, 'Color', 'y', 'LineStyle', '-');
        end
    end
%%
    function plotSignal()
        
        ha = GUI.RawDataAxes;
        
        time_data = DATA.trr;
        data = DATA.rri;
        
        Filt_time_data = DATA.tnn;
        Filt_data = DATA.nni;
        
        signal_time = time_data(DATA.FL_win_indexes(1) : DATA.FL_win_indexes(2));
        signal_data = data(DATA.FL_win_indexes(1) : DATA.FL_win_indexes(2));
        
        filt_signal_time = Filt_time_data(DATA.filt_FL_win_indexes(1) : DATA.filt_FL_win_indexes(2));
        filt_signal_data = Filt_data(DATA.filt_FL_win_indexes(1) : DATA.filt_FL_win_indexes(2));
        
        if (DATA.PlotHR == 0)
            data =  signal_data;
            filt_data =  filt_signal_data;
            yString = 'RR (sec)';
            MinYLimit = min(DATA.RRMinYLimit, DATA.RRMaxYLimit);
            MaxYLimit = max(DATA.RRMinYLimit, DATA.RRMaxYLimit);
            
            Filt_MinYLimit = min(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
            Filt_MaxYLimit = max(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
        else
            data =  60 ./ signal_data;
            filt_data =  60 ./ filt_signal_data;
            yString = 'HR (BPM)';
            MinYLimit = min(DATA.HRMinYLimit, DATA.HRMaxYLimit);
            MaxYLimit = max(DATA.HRMinYLimit, DATA.HRMaxYLimit);
            
            Filt_MinYLimit = min(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
            Filt_MaxYLimit = max(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
        end
        
        DATA.MaxYLimit = MaxYLimit;
        DATA.MinYLimit = MinYLimit;
        
        cla(ha);
        
        %         if verLessThan('matlab','9.1')
        %             % -- Code to run in MATLAB R2016a?? and earlier here --
        %             plot(ha, signal_time, data, 'b-', 'LineWidth', 2);
        %             hold(ha, 'on');
        %             plot(ha, filt_signal_time, filt_data, 'g-', 'LineWidth', 1);
        %
        %             set(ha, 'XLim', [signal_time(1) signal_time(end)]);
        %             set(ha, 'YLim', [MinYLimit MaxYLimit]);
        %             xlabel(ha, 'Time (sec)');
        %             ylabel(ha, yString);
        %
        %             rect_handle = fill([filt_signal_time(1) filt_signal_time(1) filt_signal_time(end) filt_signal_time(end)], ...
        %                 [MinYLimit MaxYLimit MaxYLimit MinYLimit], DATA.rectangle_color ,'FaceAlpha', .15, 'Parent', ha);
        %             uistack(rect_handle, 'bottom');
        %         else
        %             % -- Code to run in MATLAB R2014b and later here --
        %
        %             filt_signal_x_lim = seconds([filt_signal_time(1) filt_signal_time(end)]);
        %
        %             plot(ha, seconds(signal_time), data, 'b-', 'LineWidth', 2);
        %             hold(ha, 'on');
        %             plot(ha, seconds(filt_signal_time), filt_data, 'g-', 'LineWidth', 1);
        %
        %             set(ha, 'XLim', seconds([signal_time(1) signal_time(end)]));
        %             set(ha, 'YLim', [MinYLimit MaxYLimit]);
        %             xtickformat(ha, 'hh:mm:ss')
        %             xlabel(ha, 'Time (h:min:sec)');
        %             ylabel(ha, yString);
        %
        %             rect_handle = fill(ha, [filt_signal_x_lim(1) filt_signal_x_lim(1) filt_signal_x_lim(2) filt_signal_x_lim(2)], ...
        %                 [MinYLimit MaxYLimit MaxYLimit MinYLimit], DATA.rectangle_color ,'FaceAlpha', .15);
        %             uistack(rect_handle, 'bottom');
        %         end
        
        
        
        plot(ha, signal_time, data, 'b-', 'LineWidth', 2);
        hold(ha, 'on');
        plot(ha, filt_signal_time, filt_data, 'g-', 'LineWidth', 1);
        
        set(ha, 'XLim', [signal_time(1) signal_time(end)]);
        set(ha, 'YLim', [MinYLimit MaxYLimit]);
        xlabel(ha, 'Time (sec)');
        ylabel(ha, yString);
        
        GUI.first_rect_handle = fill([filt_signal_time(1) filt_signal_time(1) filt_signal_time(end) filt_signal_time(end)], ...
            [MinYLimit MaxYLimit MaxYLimit MinYLimit], DATA.rectangle_color ,'FaceAlpha', .15, 'Parent', ha);
        uistack(GUI.first_rect_handle, 'bottom');
        
        x_ticks_array = get(ha, 'XTick');
        set(ha, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0), x_ticks_array, 'UniformOutput', false))
        
        %h = gco(figure_handle);
        % gca Current axes or chart
        % gcbo Handle of object whose callback is executing [h,figure] = gcbo
        setAllowAxesZoom(DATA.zoom_handle, GUI.RawDataAxes, false);
        
        plotDataQuality();
    end

%%
    function plotDataQuality()
        if ~isempty(DATA.QualityAnnotations_Data)
            if ~isempty(DATA.rri)
                ha = GUI.RawDataAxes;
                MaxYLimit = DATA.MaxYLimit;
                time_data = DATA.trr;
                data = DATA.rri;
                                
                win_indexes = find(time_data >= DATA.firstSecond2Show & time_data <= DATA.firstSecond2Show + DATA.MyWindowSize);
                %signal_time = time_data(DATA.FL_win_indexes(1) : DATA.FL_win_indexes(2));
                signal_time = time_data(win_indexes(1) : win_indexes(end));
                
                qd_size = size(DATA.QualityAnnotations_Data);
                intervals_num = qd_size(1);
                
                if (DATA.PlotHR == 1)
                    data = 60 ./ data;
                end
                
                if ~isfield(GUI, 'GreenLineHandle') || ~isvalid(GUI.GreenLineHandle)
                    GUI.GreenLineHandle = line([signal_time(1) signal_time(end)], [MaxYLimit MaxYLimit], 'Color', DATA.MyGreen, 'LineWidth', 3, 'Parent', ha);
                else
                    GUI.GreenLineHandle.XData = [signal_time(1) signal_time(end)];
                    GUI.GreenLineHandle.Color = DATA.MyGreen;
                    GUI.GreenLineHandle.YData = [MaxYLimit MaxYLimit];
                end
                %---------------------------------
                
                if ~(DATA.QualityAnnotations_Data(1, 1) + DATA.QualityAnnotations_Data(1,2))==0
                    
                    if ~isfield(GUI, 'RedLineHandle') || ~isvalid(GUI.RedLineHandle(1))
                        GUI.RedLineHandle = line((DATA.QualityAnnotations_Data-time_data(1))', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                    else
                        for i = 1 : intervals_num
                            GUI.RedLineHandle(i).XData = (DATA.QualityAnnotations_Data(i, :)-time_data(1))';
                            GUI.RedLineHandle(i).YData = [MaxYLimit MaxYLimit]';
                        end
                    end
                    
                    for i = 1 : intervals_num
                        a1=find(time_data >= DATA.QualityAnnotations_Data(i,1));
                        a2=find(time_data <= DATA.QualityAnnotations_Data(i,2));
                        
                        if isempty(a2); a2 = 1; end % case where the bad quality starts before the first annotated peak
                        if isempty(a1); a1 = length(time_data); end
                        if length(a1)<2
                            low_quality_indexes = [a2(end) : a1(1)];
                        else
                            low_quality_indexes = [a2(end)-1 : a1(1)];
                        end
                        plot(time_data(low_quality_indexes), data(low_quality_indexes), '-', 'Color', [255 157 189]/255, 'LineWidth', 2.5, 'Parent', ha);
                    end
                end
                
                
                %-----------------------------------------
                %                 if ~isfield(GUI, 'GreenLineHandle') || ~isvalid(GUI.GreenLineHandle)
                %                     if verLessThan('matlab','9.1')
                %                         GUI.GreenLineHandle = line([signal_time(1) signal_time(end)], [MaxYLimit MaxYLimit], 'Color', DATA.MyGreen, 'LineWidth', 3, 'Parent', ha);
                %                     else
                %                         GUI.GreenLineHandle = line(ha, seconds([signal_time(1) signal_time(end)]), [MaxYLimit MaxYLimit], 'Color', DATA.MyGreen, 'LineWidth', 3);
                %                     end
                %                 else
                %                     if verLessThan('matlab','9.1')
                %                         GUI.GreenLineHandle.XData = [signal_time(1) signal_time(end)];
                %                     else
                %                         GUI.GreenLineHandle.XData = seconds([signal_time(1) signal_time(end)]);
                %                         GUI.GreenLineHandle.Color = DATA.MyGreen;
                %                     end
                %                     GUI.GreenLineHandle.YData = [MaxYLimit MaxYLimit];
                %                 end
                
                %                 if ~(DATA.QualityAnnotations_Data(1, 1) + DATA.QualityAnnotations_Data(1,2))==0
                %
                %                     if ~isfield(GUI, 'RedLineHandle') || ~isvalid(GUI.RedLineHandle(1))
                %                         if verLessThan('matlab','9.1')
                %                             GUI.RedLineHandle = line((DATA.QualityAnnotations_Data-time_data(1))', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                %                         else
                %                             GUI.RedLineHandle = line(ha, seconds((DATA.QualityAnnotations_Data-time_data(1))'), [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3);
                %                         end
                %                     else
                %                         for i = 1 : intervals_num
                %                             %GUI.RedLineHandle(i).XData = seconds((DATA.QualityAnnotations_Data(i, :))');
                %                             if verLessThan('matlab','9.1')
                %                                 GUI.RedLineHandle(i).XData = (DATA.QualityAnnotations_Data(i, :)-time_data(1))';
                %                             else
                %                                 GUI.RedLineHandle(i).XData = seconds((DATA.QualityAnnotations_Data(i, :)-time_data(1))');
                %                             end
                %                             GUI.RedLineHandle(i).YData = [MaxYLimit MaxYLimit]';
                %                         end
                %                     end
                %
                %                     %fr=time_data(5)-time_data(4);
                %                     %win_indexes = find(time_data >= DATA.QualityAnnotations_Data(1,1)-2*fr & time_data <= DATA.QualityAnnotations_Data(1,2)+2*fr);
                %
                %                     for i = 1 : intervals_num
                %
                %                         a1=find(time_data >= DATA.QualityAnnotations_Data(i,1));
                %                         a2=find(time_data <= DATA.QualityAnnotations_Data(i,2));
                %
                %                         %                         a2_start = a2(end);
                %                         %                         a1_stop = a1(1)+1;
                %                         if isempty(a2); a2 = 1; end % case where the bad quality starts before the first annotated peak
                %                         if isempty(a1); a1 = length(time_data); end
                %                         if length(a1)<2
                %                             low_quality_indexes = [a2(end) : a1(1)];
                %                         else
                %                             low_quality_indexes = [a2(end)-1 : a1(1)];
                %                         end
                %
                %                         %plot(ha, seconds(data_quality_time), data(win_indexes(1) : win_indexes(end)), '-', 'Color', [255 157 189]/255, 'LineWidth', 2.5);
                %                         %                         plot(ha, seconds(data_quality_time), data(win_indexes(1) : win_indexes(end)), '-s', 'Color', [255 157 189]/255, 'LineWidth', 2.5, 'MarkerSize',5,...
                %                         %                             'MarkerEdgeColor',[255 157 189]/255,...
                %                         %                             'MarkerFaceColor',[255 157 189]/255);
                %
                %                         if verLessThan('matlab','9.1')
                %                             % -- Code to run in MATLAB R2014a and earlier here --
                %                             plot(time_data(low_quality_indexes), data(low_quality_indexes), '-', 'Color', [255 157 189]/255, 'LineWidth', 2.5, 'Parent', ha);
                %                         else
                %                             % -- Code to run in MATLAB R2014b and later here --
                %                             plot(ha, seconds(time_data(low_quality_indexes)), data(low_quality_indexes), '-', 'Color', [255 157 189]/255, 'LineWidth', 2.5);
                %                         end
                %                     end
                %                 end
                
            end
        end
        setAllowAxesZoom(DATA.zoom_handle, GUI.RawDataAxes, false);
    end

%%
    function getSignal()
        firstSecond2Show =  DATA.firstSecond2Show;
        MyWindowSize = DATA.MyWindowSize;
        time_data = DATA.trr;
        
        win_indexes = find(time_data >= firstSecond2Show & time_data <= firstSecond2Show + MyWindowSize);
        DATA.FL_win_indexes =[win_indexes(1) win_indexes(end)];
    end
%%
%     function getFilteredSignal()
%         
%         Filt_FirstSecond2Show =  DATA.BatchParams.startTime;
%         Filt_MyWindowSize = DATA.BatchParams.windowLength;
%         Filt_time_data = DATA.tnn;
%         
%         filt_win_indexes = find(Filt_time_data >= Filt_FirstSecond2Show & Filt_time_data <= Filt_FirstSecond2Show + Filt_MyWindowSize);
%         DATA.filt_FL_win_indexes =[filt_win_indexes(1) filt_win_indexes(end)];
%     end

%%
    function onOpenDataQualityFile(~, ~)
        
        set_defaults_path();
        
        [DataQuality_FileName, PathName] = uigetfile({'*.mat','MAT-files (*.mat)'}, 'Open Data-Quality-Annotations File', [DIRS.dataQualityDirectory filesep]);
        if ~isequal(DataQuality_FileName, 0)
            %QualityAnnotations = load([PathName DataQuality_FileName], 'quality_anno*');
            QualityAnnotations = load([PathName DataQuality_FileName], 'Quality_anns');
            QualityAnnotations_field_names = fieldnames(QualityAnnotations);
            if ~isempty(QualityAnnotations_field_names)
                
                set(GUI.DataQuality_text, 'String', DataQuality_FileName);
                
                DATA.QualityAnnotations_Data = QualityAnnotations.(QualityAnnotations_field_names{1});
                if isfield(GUI, 'GreenLineHandle')
                    GUI = rmfield(GUI, 'GreenLineHandle');
                end
                if isfield(GUI, 'RedLineHandle')
                    GUI = rmfield(GUI, 'RedLineHandle');
                end
                plotDataQuality();
                
                DIRS.dataQualityDirectory = PathName;
            else
                errordlg('Please, choose the Data Quality Annotations File.', 'Input Error');
            end
        end
    end

%%
    function clearStatTables()
        GUI.TimeParametersTable.Data = []; %cell(1);
        GUI.TimeParametersTableData = [];
        GUI.TimeParametersTable.RowName = [];
        
        GUI.FragParametersTableData = [];
        GUI.FragParametersTable.RowName=[];
        GUI.FragParametersTable.Data = [];
        
        GUI.FrequencyParametersTable.Data = []; %cell(1);
        GUI.FrequencyParametersTableData = [];
        GUI.FrequencyParametersTable.RowName = [];
        GUI.FrequencyParametersTableMethodRowName = [];
        
        GUI.NonLinearTable.Data = []; %cell(1);
        GUI.NonLinearTableData = [];
        GUI.NonLinearTable.RowName = [];
        
        GUI.StatisticsTable.Data = []; %cell(1);
        GUI.StatisticsTable.RowName = [];
        GUI.StatisticsTable.RowName = {''};
        GUI.StatisticsTable.Data = {''};
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
    end

%%
    function onOpenFile(~, ~)
        
        %         persistent dataDirectory;
        
        %         if isempty(dataDirectory)
        %             dataDirectory = [basepath filesep 'Examples'];
        %         end
        
        %'*.qrs;*.hea; *.atr',  'WFDB Files (*.qrs,*.hea,*.atr)'; ...
        set_defaults_path();
        
        [QRS_FileName, PathName] = uigetfile( ...
            {'*.mat','MAT-files (*.mat)'; ...
            '*.qrs; *.atr',  'WFDB Files (*.qrs, *.atr)'; ...
            '*.txt','Text Files (*.txt)'}, ...
            'Open QRS File', [DIRS.dataDirectory filesep]);
        
        if ~isequal(QRS_FileName, 0)
            waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
            
            clearData();
            clear_statistics_plots();
            clearStatTables();
            clean_gui();
            
            DIRS.dataDirectory = PathName;
            
            [~, DATA.DataFileName, ExtensionFileName] = fileparts(QRS_FileName);
            
            ExtensionFileName = ExtensionFileName(2:end);
            if strcmpi(ExtensionFileName, 'mat')
                QRS = load([PathName QRS_FileName]);
                QRS_field_names = fieldnames(QRS);
                if isfield(QRS, 'Fs')
                    DATA.SamplingFrequency = QRS.Fs;
                end
                if isfield(QRS, 'mammal')
                    mammal = QRS.mammal;
                elseif isfield(QRS, 'Mammal')
                    mammal = QRS.Mammal;
                end
                if isfield(QRS, 'mammal') || isfield(QRS, 'Mammal')
                    if strcmpi(mammal, 'dogs') || strcmpi(mammal, 'dog') || strcmpi(mammal, 'canine')
                        DATA.mammal = 'dog';
                    else
                        DATA.mammal = mammal;
                    end
                    if strcmpi(mammal, 'mice') || strcmpi(mammal, 'mouse')
                        DATA.mammal = 'mouse';
                    end
                    if strcmpi(mammal, 'rabbit')
                        DATA.mammal = 'rabbit';
                    end
                    %DATA.mammal = QRS.mammal;
                    DATA.mammal_index = find(strcmp(DATA.mammals, DATA.mammal));
                    GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                else
                    GUI.Mammal_popupmenu.Value = 1;
                end
                QRS_field_names_number = length(QRS_field_names);
                i = 1;
                QRS_data = [];
                while i <= QRS_field_names_number
                    if ~isempty(regexpi(QRS_field_names{i}, 'qrs|data'))
                        QRS_data = QRS.(QRS_field_names{i});
                        break;
                    end
                    i = i + 1;
                end
                
                if ~isempty(QRS_data)
                    DATA.rri = diff(QRS_data)/DATA.SamplingFrequency;
                    DATA.trr = QRS_data(1:end-1)/DATA.SamplingFrequency;
                else
                    close(waitbar_handle);
                    errordlg('Please, choose the file with the QRS data.', 'Input Error');
                    clean_gui();
                    cla(GUI.RawDataAxes);
                    return;
                end
            elseif strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                
                try
                    [ ~, Fs, ~ ] = get_signal_channel( [PathName DATA.DataFileName] );
                    DATA.SamplingFrequency = Fs;
                catch
                    close(waitbar_handle);
                    errordlg('Cann''t get sampling frequency.', 'Input Error');
                    clean_gui();
                    cla(GUI.RawDataAxes);
                    return;
                end
                %                 fileID = fopen([PathName DATA.DataFileName '.hea' ],'r');
                %                 if fileID ~= -1
                %                     DATA.SamplingFrequency = fscanf(fileID, '%*s %*d %d', 1);
                %                     fclose(fileID);
                %                 end
                try
                    %set(GUI.Window, 'Pointer', 'watch');
                    
                    qrs_data = rdann( [PathName DATA.DataFileName], ExtensionFileName); % atr qrs
                    %set(GUI.Window, 'Pointer', 'arrow');
                    
                    if ~isempty(qrs_data)
                        DATA.rri = diff(qrs_data)/DATA.SamplingFrequency;
                        DATA.trr = qrs_data(1:end-1)/DATA.SamplingFrequency;
                    else
                        errordlg('Please, choose the file with the QRS data.', 'Input Error');
                        clean_gui();
                        cla(GUI.RawDataAxes);
                        return;
                    end
                    GUI.Mammal_popupmenu.Value = 1;
                    DATA.mammal = 'human';
                catch e
                    close(waitbar_handle);
                    errordlg(['onOpenFile error: ' e.message], 'Input Error');
                    clearData();
                    clear_statistics_plots();
                    clearStatTables();
                    clean_gui();
                    cla(GUI.RawDataAxes);
                    return;
                end
            elseif strcmpi(ExtensionFileName, 'txt')
                file_name = [PathName DATA.DataFileName '.txt'];
                fileID = fopen(file_name, 'r');
                if fileID ~= -1
                    mammal = fscanf(fileID, '%*s %s', 1);
                    if strcmpi(mammal, 'mice')
                        DATA.mammal = 'mouse';
                    else
                        DATA.mammal = mammal;
                    end
                    DATA.SamplingFrequency = fscanf(fileID, '%*s %d', 1);
                    DATA.integration = fscanf(fileID, '%*s %s', 1);
                    txt_data = dlmread(file_name,' ',4,0);
                    fclose(fileID);
                    DATA.mammal_index = find(strcmpi(DATA.mammals, DATA.mammal));
                    GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                    if ~isempty(txt_data)
                        DATA.rri = diff(txt_data)/DATA.SamplingFrequency;
                        DATA.trr = txt_data(1:end-1)/DATA.SamplingFrequency;
                    else
                        close(waitbar_handle);
                        errordlg('Please, choose the file with the QRS data.', 'Input Error');
                        clean_gui();
                        cla(GUI.RawDataAxes);
                        return;
                    end
                end
            else
                close(waitbar_handle);
                errordlg('Please, choose another file format.', 'Input Error');
                return;
            end
            
            DATA.mammal_index = get(GUI.Mammal_popupmenu,'Value');
            rhrv_load_defaults(DATA.mammals{ DATA.mammal_index } );
            waitbar(2 / 2, waitbar_handle, 'Create Config Parameters Windows');
            createConfigParametersInterface();
            close(waitbar_handle);
            
            reset_plot();
            
            set(GUI.DataQualityMenu, 'Enable', 'on');
            if isfield(GUI, 'RawDataAxes')
                PathName = strrep(PathName, '\', '\\');
                PathName = strrep(PathName, '_', '\_');
                QRS_FileName_title = strrep(QRS_FileName, '_', '\_');
                
                TitleName = [PathName QRS_FileName_title] ;
                title(GUI.RawDataAxes, TitleName, 'FontWeight', 'normal', 'FontSize', DATA.SmallFontSize);
                
                set(GUI.RecordName_text, 'String', QRS_FileName);
            end
            set(GUI.SaveAsMenu, 'Enable', 'on');
            set(GUI.SaveFiguresAsMenu, 'Enable', 'on');
            set(GUI.SaveParamFileMenu, 'Enable', 'on');
            set(GUI.LoadConfigFile, 'Enable', 'on');
        end
    end
%%
%     function stat_data_cell = str2cellStatisticsParam(stat_struct)
%
%         stat_struct_names = fieldnames(stat_struct);
%         str_names_num = length(stat_struct_names);
%
%         stat_data_cell = cell(str_names_num, 1);
%
%         for i = 1 : str_names_num
%             stat_data_cell{i, 1} = stat_struct.(stat_struct_names{i});
%         end
%     end
%%
    function [stat_data_cell, stat_row_names_cell, stat_descriptions_cell] = table2cell_StatisticsParam(stat_table)
        
        variables_num = length(stat_table.Properties.VariableNames);
        stat_data_cell = cell(variables_num, 1);
        stat_row_names_cell = cell(variables_num, 1);
        stat_descriptions_cell = cell(variables_num, 1);
        
        table_properties = stat_table.Properties;
        for i = 1 : variables_num
            var_name = table_properties.VariableNames{i};
            %stat_data_cell{i, 1} = stat_table.(var_name);
            stat_data_cell{i, 1} = sprintf('%.2f', stat_table.(var_name));
            stat_row_names_cell{i, 1} = [var_name ' (' table_properties.VariableUnits{i} ')'];
            stat_descriptions_cell{i, 1} = table_properties.VariableDescriptions{i};
        end
    end

%%
    function old_calcTimeStatistics()
        % Save processing start time
        t0 = cputime;
        
        Filt_data = DATA.nni;
        
        nni_window = Filt_data(DATA.filt_FL_win_indexes(1) : DATA.filt_FL_win_indexes(2));
        
        try
            % Time Domain metrics
            fprintf('[%.3f] >> rhrv: Calculating time-domain metrics...\n', cputime-t0);
            [hrv_td, pd_time] = hrv_time(nni_window);
            
            DATA.hrv_td = hrv_td;
            DATA.pd_time = pd_time;
            
            [DATA.timeData, DATA.timeRowsNames, DATA.timeDescriptions] = table2cell_StatisticsParam(DATA.hrv_td);
            
            GUI.TimeParametersTableRowName = DATA.timeRowsNames;
            GUI.TimeParametersTableData = [DATA.timeDescriptions DATA.timeData];
            GUI.TimeParametersTable.Data = [DATA.timeRowsNames DATA.timeData];
        catch e
            errordlg(['hrv_time error: ' e.message], 'Input Error');
            DATA.flag = 'hrv_time';
            rethrow(e);
        end
        
        %--------------------------------------------------------------
        
        try
            % Heart rate fragmentation metrics
            fprintf('[%.3f] >> rhrv: Calculating fragmentation metrics...\n', cputime-t0);
            hrv_frag = hrv_fragmentation(nni_window);
            
            DATA.hrv_frag = hrv_frag;
            
            [DATA.fragData, DATA.fragRowsNames, DATA.fragDescriptions] = table2cell_StatisticsParam(DATA.hrv_frag);
            
            GUI.FragParametersTableRowName = DATA.fragRowsNames;
            GUI.FragParametersTableData = [DATA.fragDescriptions DATA.fragData];
            GUI.FragParametersTable.Data = [DATA.fragRowsNames DATA.fragData];
        catch e
            errordlg(['hrv_fragmentation error: ' e.message], 'Input Error');
            DATA.flag = 'hrv_fragmentation';
            rethrow(e);
        end
        updateTimeStatistics();
        updateStatisticsTable();
    end
%%
    function updateTimeStatistics()
        GUI.TimeParametersTableRowName = [GUI.TimeParametersTableRowName; GUI.FragParametersTableRowName];
        GUI.TimeParametersTableData = [GUI.TimeParametersTableData; GUI.FragParametersTableData];
        GUI.TimeParametersTable.Data = [GUI.TimeParametersTable.Data; GUI.FragParametersTable.Data];
    end
%%
    function old_calcFrequencyStatistics()
        % Save processing start time
        t0 = cputime;
        Filt_data = DATA.nni;
        
        nni_window = Filt_data(DATA.filt_FL_win_indexes(1) : DATA.filt_FL_win_indexes(2));
        try
            % Freq domain metrics
            fprintf('[%.3f] >> rhrv: Calculating frequency-domain metrics...\n', cputime-t0);
            
            [ hrv_fd, ~, ~, pd_freq ] = hrv_freq(nni_window, 'methods', {'lomb','welch','ar'},...
                'power_methods', {'lomb','welch','ar'});
            
            hrv_fd_lomb = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_lomb')), hrv_fd.Properties.VariableNames)));
            hrv_fd_ar = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_ar')), hrv_fd.Properties.VariableNames)));
            hrv_fd_welch = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, 'welch')), hrv_fd.Properties.VariableNames)));
            
            DATA.hrv_fd = hrv_fd;
            DATA.pd_freq = pd_freq;
            
            DATA.hrv_fd_lomb = hrv_fd_lomb;
            DATA.hrv_fd_ar = hrv_fd_ar;
            DATA.hrv_fd_welch = hrv_fd_welch;
            
            [DATA.fd_lombData, DATA.fd_LombRowsNames, DATA.fd_lombDescriptions] = table2cell_StatisticsParam(DATA.hrv_fd_lomb);
            [DATA.fd_arData, DATA.fd_ArRowsNames, DATA.fd_ArDescriptions] = table2cell_StatisticsParam(DATA.hrv_fd_ar);
            [DATA.fd_welchData, DATA.fd_WelchRowsNames, DATA.fd_WelchDescriptions] = table2cell_StatisticsParam(DATA.hrv_fd_welch);
            
            GUI.FrequencyParametersTableLombRowName = DATA.fd_LombRowsNames;
            GUI.FrequencyParametersTableRowName = strrep(DATA.fd_LombRowsNames,'_LOMB','');
            
            GUI.FrequencyParametersTable.Data = [GUI.FrequencyParametersTableRowName DATA.fd_lombData DATA.fd_welchData DATA.fd_arData];
            
            setFrequencyParametersTableMethodRowName();
        catch e
            errordlg(['hrv_freq error: ' e.message], 'Input Error');
            DATA.flag = 'hrv_freq';
            rethrow(e);
        end
        updateStatisticsTable();
    end
%%
    function old_calcNolinearStatistics()
        % Save processing start time
        t0 = cputime;
        Filt_data = DATA.nni;
        
        nni_window = Filt_data(DATA.filt_FL_win_indexes(1) : DATA.filt_FL_win_indexes(2));
        try
            % Non linear metrics
            fprintf('[%.3f] >> rhrv: Calculating nonlinear metrics...\n', cputime-t0);
            [hrv_nl, pd_nl] = hrv_nonlinear(nni_window);
            
            DATA.hrv_nl = hrv_nl;
            DATA.pd_nl = pd_nl;
            
            [DATA.nonlinData, DATA.nonlinRowsNames, DATA.nonlinDescriptions] = table2cell_StatisticsParam(DATA.hrv_nl);
            
            GUI.NonLinearTableRowName = DATA.nonlinRowsNames;
            GUI.NonLinearTableData = [DATA.nonlinDescriptions DATA.nonlinData];
            %GUI.NonLinearTable.Data = DATA.nonlinData;
            GUI.NonLinearTable.Data = [DATA.nonlinRowsNames DATA.nonlinData];
            %--------------------------------------------------------------
        catch e
            errordlg(['hrv_nonlinear: ' e.message], 'Input Error');
            DATA.flag = 'hrv_nonlinear';
            rethrow(e);
        end
        updateStatisticsTable();
    end
%%
    function updateStatisticsTable()
        GUI.StatisticsTable.RowName = cat(1, GUI.TimeParametersTableRowName, GUI.FrequencyParametersTableMethodRowName, GUI.NonLinearTableRowName);
        GUI.StatisticsTable.Data = cat(1, GUI.TimeParametersTableData, GUI.FrequencyParametersTableData, GUI.NonLinearTableData);
    end
%%
    function clear_statistics_plots()
        clear_time_statistics_results();
        clear_frequency_statistics_results();
        clear_nonlinear_statistics_results();
    end
%%
    function clear_time_statistics_results()
        grid(GUI.TimeAxes1, 'off');
        legend(GUI.TimeAxes1, 'off')
        cla(GUI.TimeAxes1);
    end
%%
    function clear_frequency_statistics_results()
        grid(GUI.FrequencyAxes1, 'off');
        grid(GUI.FrequencyAxes2, 'off');
        legend(GUI.FrequencyAxes1, 'off');
        legend(GUI.FrequencyAxes2, 'off');
        cla(GUI.FrequencyAxes1);
        cla(GUI.FrequencyAxes2);
    end
%%
    function clear_nonlinear_statistics_results()
        grid(GUI.NonLinearAxes1, 'off');
        grid(GUI.NonLinearAxes2, 'off');
        grid(GUI.NonLinearAxes3, 'off');
        
        legend(GUI.NonLinearAxes1, 'off');
        legend(GUI.NonLinearAxes2, 'off');
        legend(GUI.NonLinearAxes3, 'off');
        
        cla(GUI.NonLinearAxes1);
        cla(GUI.NonLinearAxes2);
        cla(GUI.NonLinearAxes3);
    end
%%
    function plot_time_statistics_results()
        
        clear_time_statistics_results();
        
        if ~isempty(DATA.pd_time)
            plot_hrv_time_hist(GUI.TimeAxes1, DATA.pd_time, 'clear', true);
        end
        box(GUI.TimeAxes1, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, GUI.TimeAxes1, false);
    end
%%
    function plot_frequency_statistics_results()
        
        clear_frequency_statistics_results();
        
        if ~isempty(DATA.pd_freq)
            plot_hrv_freq_spectrum(GUI.FrequencyAxes1, DATA.pd_freq, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
            plot_hrv_freq_beta(GUI.FrequencyAxes2, DATA.pd_freq);
        end
        box(GUI.FrequencyAxes1, 'off' );
        box(GUI.FrequencyAxes2, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, GUI.FrequencyAxes2, false);
    end
%%
    function plot_nonlinear_statistics_results()
        
        clear_nonlinear_statistics_results();
        
        if ~isempty(DATA.pd_nl)
            plot_dfa_fn(GUI.NonLinearAxes1, DATA.pd_nl.dfa);
            plot_mse(GUI.NonLinearAxes3, DATA.pd_nl.mse);
            plot_poincare_ellipse(GUI.NonLinearAxes2, DATA.pd_nl.poincare);
        end
        box(GUI.NonLinearAxes1, 'off' );
        box(GUI.NonLinearAxes2, 'off' );
        box(GUI.NonLinearAxes3, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, [GUI.NonLinearAxes1, GUI.NonLinearAxes2, GUI.NonLinearAxes3], false);
    end
%%
%     function set_filter_mammal_integ_param(filter_index, mammal_index, integration_index)
%
%         DATA.filter_index = filter_index;
%         set_filters(DATA.Filters{DATA.filter_index});
%
%         DATA.mammal_index = mammal_index;
%         % Load user-specified default parameters
%         rhrv_load_defaults(DATA.mammals{ DATA.mammal_index} );
%         createConfigParametersInterface();
%
%         GUI.Mammal_popupmenu.Value = mammal_index;
%         GUI.Filtering_popupmenu.Value = filter_index;
%         GUI.Integration_popupmenu.Value = integration_index;
%
%         %         DATA.Integration = 'ECG';
%         %         DATA.integration_index = integration_index;
%
%     end
%%
    function reset_plot()
        
        if ~isempty(DATA.rri)
            
            trr = DATA.trr;
            rri = DATA.rri;
            
            %DATA.maxSignalLength = int64(trr(end));
            DATA.maxSignalLength = trr(end);
            
            DATA.PlotHR = 0;
            DATA.firstSecond2Show = 0;
            %DATA.Filt_FirstSecond2Show = 0;
            DATA.MyWindowSize = DATA.maxSignalLength;
            
            setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, 0, [0.01 , 0.1]);
            
            try
                %waitbar(3 / 6, DATA.waitbar_handle, 'Filtering the signal');
                % Only for calc min and max bounderies for plotting
                FiltSignal('filter_quotient', false, 'filter_lowpass', true, 'filter_range', false);
                
                tnn = DATA.tnn;
                nni = DATA.nni;
                
                if length(rri) == length(nni)
                    DATA.RRMinYLimit = min(rri);
                    DATA.RRMaxYLimit = max(rri);
                    
                    max_rri_60 = max(60 ./ rri);
                    min_rri_60 = min(60 ./ rri);
                    DATA.HRMinYLimit = min(min_rri_60, max_rri_60);
                    DATA.HRMaxYLimit = max(min_rri_60, max_rri_60);
                else
                    max_nni = max(nni);
                    min_nni = min(nni);
                    delta = (max_nni - min_nni)*1;
                    
                    DATA.RRMinYLimit = min_nni - delta;
                    DATA.RRMaxYLimit = max_nni + delta;
                    
                    max_nni_60 = max(60 ./ nni);
                    min_nni_60 = min(60 ./ nni);
                    delta_60 = (max_nni_60 - min_nni_60)*1;
                    
                    DATA.HRMinYLimit = min(min_nni_60, max_nni_60) - delta_60;
                    DATA.HRMaxYLimit = max(min_nni_60, max_nni_60) + delta_60;
                end
                
                DATA.Filt_MyDefaultWindowSize = rhrv_get_default('hrv_freq.window_minutes', 'value') * 60; % min to sec
                
                %DATA.Filt_MaxSignalLength = int64(tnn(end));
                DATA.Filt_MaxSignalLength = tnn(end);
                
                %DATA.Filt_MyWindowSize = min(DATA.Filt_MaxSignalLength, DATA.Filt_MyDefaultWindowSize);
                %DATA.Filt_MyDefaultWindowSize = DATA.Filt_MyWindowSize;
                
                set(GUI.freq_yscale_Button, 'String', 'Log');
                set(GUI.freq_yscale_Button, 'Value', 1);
                DATA.freq_yscale = 'linear';
                
                DATA.DEFAULT_BatchParams.startTime = 0;
                DATA.DEFAULT_BatchParams.endTime = DATA.Filt_MaxSignalLength; %DATA.Filt_MyDefaultWindowSize;
                DATA.DEFAULT_BatchParams.effectiveEndTime = DATA.Filt_MyDefaultWindowSize;
                DATA.DEFAULT_BatchParams.windowLength = min(DATA.Filt_MaxSignalLength, DATA.Filt_MyDefaultWindowSize);
                DATA.DEFAULT_BatchParams.overlap = 0;
                DATA.DEFAULT_BatchParams.winNum = 1;
                
                clean_gui_batch_params();
                
                %                 if DATA.filter_index == 1 % LowPass
                %                     CalcPlotSignalStat();
                %                 else
                %                     FiltSignal();
                %                     CalcPlotSignalStat();
                %                 end
                
                if DATA.filter_index ~= 1 % LowPass
                    FiltSignal();
                end
                
                cla(GUI.RawDataAxes);
                clear_statistics_plots();
                clearStatTables();
                plotRawData();
                setXAxesLim();
                setYAxesLim();
                plotFilteredData();
                plotDataQuality();
                plotMultipleWindows();
                calcStatistics();
                
                DATA.Filt_RRMinYLimit = min(nni);
                DATA.Filt_RRMaxYLimit = max(nni);
                
                DATA.Filt_HRMinYLimit = min(60 / DATA.Filt_RRMinYLimit, 60 / DATA.Filt_RRMaxYLimit);
                DATA.Filt_HRMaxYLimit = max(60 / DATA.Filt_RRMinYLimit, 60 / DATA.Filt_RRMaxYLimit);
                
                setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
                
                %                 set(GUI.Filt_MinYLimit_Edit, 'String', num2str(DATA.Filt_RRMinYLimit));
                %                 set(GUI.Filt_MaxYLimit_Edit, 'String', num2str(DATA.Filt_RRMaxYLimit));
                set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                set(GUI.Filt_WindowSize, 'String', calcDuration(DATA.BatchParams.windowLength, 0));
                set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
                
                set(GUI.MinYLimit_Edit, 'String', num2str(DATA.RRMinYLimit));
                set(GUI.MaxYLimit_Edit, 'String', num2str(DATA.RRMaxYLimit));
                set(GUI.RawDataSlider, 'Enable', 'off');
                ws = calcDuration(DATA.MyWindowSize, 1);
                set(GUI.WindowSize, 'String', ws);
                set(GUI.RecordLength_text, 'String', [ws '    h:min:sec.msec']);
                set(GUI.RR_or_HR_plot_button, 'Enable', 'on', 'Value', 0, 'String', 'Plot HR');
                %                 set(GUI.RR_or_HR_plot_button, 'Value', 0);
                %                 set(GUI.RR_or_HR_plot_button, 'String', 'Plot HR');
                set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0), 'Enable', 'off');
                
                if(DATA.BatchParams.windowLength >= DATA.Filt_MaxSignalLength)
                    set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0), 'Enable', 'off');
                    set(GUI.Filt_RawDataSlider, 'Enable', 'off');
                else
                    set(GUI.Filt_FirstSecond, 'Enable', 'on');
                    set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                end
                GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
                
                set(GUI.Filt_WindowSize, 'Enable', 'on');
                set(GUI.Filt_FirstSecond, 'Enable', 'on');
            catch e
                errordlg(['Reset Plot: ' e.message], 'Input Error');
            end
        end
    end % reset

%%
    function setSliderProperties(slider_handle, maxSignalLength, MyWindowSize, SliderStep)
        set(slider_handle, 'Min', 0);
        %set(slider_handle, 'Max', maxSignalLength - MyWindowSize + 1);
        set(slider_handle, 'Max', maxSignalLength - MyWindowSize);
        set(slider_handle, 'Value', 0);
        set(slider_handle, 'SliderStep', SliderStep);
    end

%%
    function isInputNumeric = isInputNumeric(GUIFiled, NewFieldValue, OldFieldValue)
        if isnan(NewFieldValue)
            set(GUIFiled,'String', OldFieldValue);
            isInputNumeric = false;
            warndlg('Input must be numerical');
        else
            isInputNumeric = true;
        end
    end

%%
    function WindowSize_Callback(~, ~)
        
        if ~isempty(DATA.rri)
            MyWindowSize = get(GUI.WindowSize,'String');
            [MyWindowSize, isInputNumeric]  = calcDurationInSeconds(GUI.WindowSize, MyWindowSize, DATA.MyWindowSize);
            
            if isInputNumeric
                
                if MyWindowSize <= 1 || MyWindowSize > DATA.maxSignalLength
                    set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
                    errordlg('The window size must be greater then 2 sec and less then signal length!', 'Input Error');
                    return;
                end
                
                if(MyWindowSize == DATA.maxSignalLength)
                    set(GUI.RawDataSlider, 'Enable', 'off');
                    set(GUI.FirstSecond, 'Enable', 'off');
                else
                    set(GUI.RawDataSlider, 'Enable', 'on');
                    set(GUI.FirstSecond, 'Enable', 'on');
                end
                
                DATA.MyWindowSize = MyWindowSize;
                setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, [(DATA.MyWindowSize/10)/double(DATA.maxSignalLength) , (DATA.MyWindowSize)/double(DATA.maxSignalLength) ]);
                %plotRawData();
                setXAxesLim();
            end
            
            
            %             if isInputNumeric
            %                 if(MyWindowSize == DATA.maxSignalLength)
            %                     set(GUI.RawDataSlider, 'Enable', 'off');
            %                     set(GUI.FirstSecond, 'Enable', 'off');
            %                     DATA.MyWindowSize = MyWindowSize;
            %                     DATA.firstSecond2Show = 0;
            %                     DATA.BatchParams.startTime = 0;
            %                     set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
            %                     set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
            %                     setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
            %                     %CalcPlotSignalStat();
            %                     plotRawData();
            %                 elseif(MyWindowSize > DATA.maxSignalLength)
            %                     set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
            %                     errordlg('The window size must be less then signal length!', 'Input Error');
            %                 elseif (MyWindowSize <= 1)
            %                     set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
            %                     errordlg('The window size must be greater then 2 sec!', 'Input Error');
            %                 else
            %                     set(GUI.RawDataSlider, 'Enable', 'on');
            %                     set(GUI.FirstSecond, 'Enable', 'on');
            %                     DATA.MyWindowSize = MyWindowSize;
            %                     DATA.firstSecond2Show = 0;
            %                     DATA.BatchParams.startTime = 0;
            %                     set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
            %                     set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
            %                     setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, [(DATA.MyWindowSize/10)/double(DATA.maxSignalLength) , (DATA.MyWindowSize)/double(DATA.maxSignalLength) ]);
            %                     setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
            %                     %CalcPlotSignalStat();
            %                     plotRawData();
            %                 end
            %             end
        end
    end

%%
    function Filt_WindowSize_Callback(~, ~)
        if ~isempty(DATA.rri)
            Filt_MyWindowSize = get(GUI.Filt_WindowSize,'String');
            [Filt_MyWindowSize, isInputNumeric]  = calcDurationInSeconds(GUI.Filt_WindowSize, Filt_MyWindowSize, DATA.BatchParams.windowLength);
            
            if isInputNumeric
                if Filt_MyWindowSize <= 10 || Filt_MyWindowSize > DATA.Filt_MaxSignalLength
                    set(GUI.Filt_WindowSize,'String', calcDuration(DATA.BatchParams.windowLength, 0));
                    errordlg('The filt window size must be greater then 10 sec and less then signal length!', 'Input Error');
                    return;
                end
                
                DATA.BatchParams.startTime = 0;
                DATA.BatchParams.endTime = Filt_MyWindowSize;
                DATA.BatchParams.windowLength = Filt_MyWindowSize;
                setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
                set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
                set(GUI.batch_startTime, 'String', calcDuration(DATA.BatchParams.startTime, 0));
                set(GUI.batch_endTime, 'String', calcDuration(DATA.BatchParams.endTime, 1));
                set(GUI.batch_windowLength, 'String', calcDuration(DATA.BatchParams.windowLength, 1));
                clear_statistics_plots();
                clearStatTables();
                calcBatchWinNum();
                plotFilteredData();
                plotMultipleWindows();                
                calcStatistics();
                
                if Filt_MyWindowSize == DATA.Filt_MaxSignalLength
                    set(GUI.Filt_RawDataSlider, 'Enable', 'off');
                    set(GUI.Filt_FirstSecond, 'Enable', 'off');
                else
                    set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                    set(GUI.Filt_FirstSecond, 'Enable', 'on');
                end
            end
            
            
            
            %             if isInputNumeric
            %                 if(Filt_MyWindowSize == DATA.Filt_MaxSignalLength)
            %                     set(GUI.Filt_RawDataSlider, 'Enable', 'off');
            %                     set(GUI.Filt_FirstSecond, 'Enable', 'off');
            %                     %DATA.Filt_MyWindowSize = Filt_MyWindowSize;
            %                     %DATA.Filt_FirstSecond2Show = 0;
            %                     DATA.BatchParams.startTime = 0;
            %                     DATA.BatchParams.endTime = Filt_MyWindowSize;
            %                     DATA.BatchParams.windowLength = Filt_MyWindowSize;
            %                     set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
            %                     set(GUI.batch_startTime, 'String', calcDuration(DATA.BatchParams.startTime, 0));
            %                     set(GUI.batch_endTime, 'String', calcDuration(DATA.BatchParams.endTime, 0));
            %                     set(GUI.batch_windowLength, 'String', calcDuration(DATA.BatchParams.windowLength, 0));
            %                     calcBatchWinNum();
            %                     plotMultipleWindows();
            %                     plotFilteredData();
            %                     %CalcPlotSignalStat();
            %                     calcStatistics();
            %                 elseif(Filt_MyWindowSize > DATA.Filt_MaxSignalLength)
            %                     set(GUI.Filt_WindowSize,'String', calcDuration(DATA.BatchParams.windowLength, 0));
            %                     errordlg('The filt window size must be less then signal length!', 'Input Error');
            %                 elseif (Filt_MyWindowSize <= 10)
            %                     set(GUI.Filt_WindowSize,'String', calcDuration(DATA.BatchParams.windowLength, 0));
            %                     errordlg('The filt window size must be greater then 10 sec!', 'Input Error');
            %                 else
            %                     set(GUI.Filt_RawDataSlider, 'Enable', 'on');
            %                     set(GUI.Filt_FirstSecond, 'Enable', 'on');
            %                     %DATA.Filt_MyWindowSize = Filt_MyWindowSize;
            %                     %DATA.Filt_FirstSecond2Show = 0;
            %                     DATA.BatchParams.startTime = 0;
            %                     DATA.BatchParams.endTime = Filt_MyWindowSize;
            %                     DATA.BatchParams.windowLength = Filt_MyWindowSize;
            %                     set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
            %                     setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
            %                     set(GUI.batch_startTime, 'String', calcDuration(DATA.BatchParams.startTime, 0));
            %                     set(GUI.batch_endTime, 'String', calcDuration(DATA.BatchParams.endTime, 0));
            %                     set(GUI.batch_windowLength, 'String', calcDuration(DATA.BatchParams.windowLength, 0));
            %                     calcBatchWinNum();
            %                     plotMultipleWindows();
            %                     plotFilteredData();
            %                     calcStatistics();
            %                     %CalcPlotSignalStat();
            %                 end
            %             end
        end
    end
%%
    function MinYLimit_Edit_Callback(~, ~)
        if ~isempty(DATA.rri)
            MinYLimit = str2double(get(GUI.MinYLimit_Edit,'String'));
            if (DATA.PlotHR == 0)
                OldMinYLimit = DATA.RRMinYLimit;
            else
                OldMinYLimit = DATA.HRMinYLimit;
            end
            if isInputNumeric(GUI.MinYLimit_Edit, MinYLimit, OldMinYLimit)
                
                if (DATA.PlotHR == 0)
                    DATA.RRMinYLimit = MinYLimit;
                    MinYLimit = min(DATA.RRMinYLimit, DATA.RRMaxYLimit);
                    MaxYLimit = max(DATA.RRMinYLimit, DATA.RRMaxYLimit);
                else
                    DATA.HRMinYLimit = MinYLimit;
                    MinYLimit = min(DATA.HRMinYLimit, DATA.HRMaxYLimit);
                    MaxYLimit = max(DATA.HRMinYLimit, DATA.HRMaxYLimit);
                end
                
                if(MinYLimit ~= MaxYLimit)
                    set(GUI.RawDataAxes, 'YLim', [MinYLimit MaxYLimit]);
                    DATA.MinYLimit = MinYLimit;
                    DATA.MaxYLimit = MaxYLimit;
                    plotDataQuality();
                    plotMultipleWindows();
                else
                    errordlg('Please, enter correct values!', 'Input Error');
                end
            end
        end
    end
%%
    function MaxYLimit_Edit_Callback( ~, ~ )
        if ~isempty(DATA.rri)
            MaxYLimit = str2double(get(GUI.MaxYLimit_Edit,'String'));
            if (DATA.PlotHR == 0)
                OldMaxYLimit = DATA.RRMaxYLimit;
            else
                OldMaxYLimit = DATA.HRMaxYLimit;
            end
            if isInputNumeric(GUI.MaxYLimit_Edit, MaxYLimit, OldMaxYLimit)
                
                if (DATA.PlotHR == 0)
                    DATA.RRMaxYLimit = MaxYLimit;
                    MinYLimit = min(DATA.RRMinYLimit, DATA.RRMaxYLimit);
                    MaxYLimit = max(DATA.RRMinYLimit, DATA.RRMaxYLimit);
                else
                    DATA.HRMaxYLimit = MaxYLimit;
                    MinYLimit = min(DATA.HRMinYLimit, DATA.HRMaxYLimit);
                    MaxYLimit = max(DATA.HRMinYLimit, DATA.HRMaxYLimit);
                end
                if(MinYLimit ~= MaxYLimit)
                    set(GUI.RawDataAxes, 'YLim', [MinYLimit MaxYLimit]);
                       DATA.MinYLimit = MinYLimit;
                    DATA.MaxYLimit = MaxYLimit;
                    plotDataQuality();
                    plotMultipleWindows();                    
                else
                    errordlg('Please, Enter correct values!', 'Input Error');
                end
            end
        end
    end
%%
    function RR_or_HR_plot_button_Callback( ~, ~ )
        if ~isempty(DATA.rri)
            if(DATA.PlotHR == 1)
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot HR');
                DATA.PlotHR = 0;
                %                 MinYLimit = min(DATA.RRMinYLimit, DATA.RRMaxYLimit);
                %                 MaxYLimit = max(DATA.RRMinYLimit, DATA.RRMaxYLimit);
                %
                %                 Filt_MinYLimit = min(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
                %                 Filt_MaxYLimit = max(DATA.Filt_RRMinYLimit, DATA.Filt_RRMaxYLimit);
            else
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot RR');
                DATA.PlotHR = 1;
                %                 MinYLimit = min(DATA.HRMinYLimit, DATA.HRMaxYLimit);
                %                 MaxYLimit = max(DATA.HRMinYLimit, DATA.HRMaxYLimit);
                %
                %                 Filt_MinYLimit = min(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
                %                 Filt_MaxYLimit = max(DATA.Filt_HRMinYLimit, DATA.Filt_HRMaxYLimit);
            end
            
            cla(GUI.RawDataAxes);
            plotRawData();
            setXAxesLim();
            setYAxesLim();
            plotFilteredData();
            plotDataQuality();
            plotMultipleWindows();
            
            set(GUI.MinYLimit_Edit, 'String', num2str(DATA.MinYLimit));
            set(GUI.MaxYLimit_Edit, 'String', num2str(DATA.MaxYLimit));
            
            %             set(GUI.Filt_MinYLimit_Edit, 'String', num2str(Filt_MinYLimit));
            %             set(GUI.Filt_MaxYLimit_Edit, 'String', num2str(Filt_MaxYLimit));
            
            %             DATA.MinYLimit = MinYLimit;
            %             DATA.MaxYLimit = MaxYLimit;
            
            %GetPlotSignal();
        end
    end
%%
    function set_defaults_path()
        
        %         persistent ExportResultsDirectory;
        %         persistent dataDirectory;
        %         persistent configDirectory;
        %         persistent dataQualityDirectory;
        
        if ~isfield(DIRS, 'dataDirectory') %isempty(DIRS.dataDirectory)
            DIRS.dataDirectory = [basepath filesep 'Examples'];
        end
        if ~isfield(DIRS, 'configDirectory') %isempty(DIRS.configDirectory)
            DIRS.configDirectory = [basepath filesep 'Config'];
        end
        if ~isfield(DIRS, 'ExportResultsDirectory') %isempty(DIRS.ExportResultsDirectory)
            DIRS.ExportResultsDirectory = [basepath filesep 'Results'];
        end
        if ~isfield(DIRS, 'dataQualityDirectory') %isempty(DIRS.dataQualityDirectory)
            DIRS.dataQualityDirectory = [basepath filesep 'Examples'];
        end
    end
%%
    function reset_defaults_path()
        DIRS.dataDirectory = [basepath filesep 'Examples'];
        DIRS.configDirectory = [basepath filesep 'Config'];
        DIRS.ExportResultsDirectory = [basepath filesep 'Results'];
    end
%%
    function Reset_pushbutton_Callback( ~, ~ )
        
        reset_defaults_path();
        DATA_Fig.export_figures = [1 1 1 1 1 1];
        DATA_Fig.export_figures_formats_index = 1;
        
        DATA.filter_index = 1;
        set_filters(DATA.Filters{DATA.filter_index});
        
        if isempty(DATA.mammal)
            mammal_index = 1;
        else
            mammal_index = find(strcmp(DATA.mammals, DATA.mammal));
        end
        
        DATA.mammal_index = mammal_index;
        DATA.default_method_index = 2;
        
        % Load user-specified default parameters
        rhrv_load_defaults(DATA.mammals{ DATA.mammal_index} );
        createConfigParametersInterface();
        
        GUI.Mammal_popupmenu.Value = mammal_index;
        GUI.Filtering_popupmenu.Value = DATA.filter_index;
        GUI.Integration_popupmenu.Value = 1;
        GUI.DefaultMethod_popupmenu.Value = DATA.default_method_index;
        
        reset_plot();
    end

%%
    function FiltSignal(varargin)
        
        DEFAULT_FILTER_QUOTIENT = DATA.filter_quotient;
        DEFAULT_FILTER_LOWPASS = DATA.filter_lowpass;
        DEFAULT_FILTER_RANGE = DATA.filter_range;
        p = inputParser;
        p.KeepUnmatched = true;
        p.addParameter('filter_quotient', DEFAULT_FILTER_QUOTIENT, @(x) islogical(x) && isscalar(x));
        p.addParameter('filter_lowpass', DEFAULT_FILTER_LOWPASS, @(x) islogical(x) && isscalar(x));
        p.addParameter('filter_range', DEFAULT_FILTER_RANGE, @(x) islogical(x) && isscalar(x));
        % Get input
        p.parse(varargin{:});
        filter_quotient = p.Results.filter_quotient;
        filter_lowpass = p.Results.filter_lowpass;
        filter_range = p.Results.filter_range;
        
        if ~isempty(DATA.rri)
            
            [nni, tnn, ~] = filtrr(DATA.rri, DATA.trr, 'filter_quotient', filter_quotient, 'filter_lowpass', filter_lowpass, 'filter_range', filter_range);
            
            if (isempty(nni))
                ME = MException('FiltCalcPlotSignalStat:FiltrrNoNNIntervalOutputted', 'No NN interval outputted');
                throw(ME);
            elseif (length(DATA.rri) * 0.1 > length(nni))
                ME = MException('FiltCalcPlotSignalStat:NotEnoughNNIntervals', 'Not enough NN intervals');
                throw(ME);
            else
                DATA.nni = nni;
                DATA.tnn = tnn;
            end
        end
    end
%%
    function CalcPlotSignalStat()
        GetPlotSignal();
        try
            
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            
            waitbar(1 / 3, waitbar_handle, 'Calculating Time Measures');
            old_calcTimeStatistics();
            plot_time_statistics_results();
            
            waitbar(2 / 3, waitbar_handle, 'Calculating Frequency Measures');
            old_calcFrequencyStatistics();
            plot_frequency_statistics_results();
            
            waitbar(3 / 3, waitbar_handle, 'Calculating Nolinear Measures');
            old_calcNolinearStatistics();
            plot_nonlinear_statistics_results();
            close(waitbar_handle);
            
        catch e
            %             if ~isempty(DATA.waitbar_handle)
            %                 close(DATA.waitbar_handle);
            %             end
            close(waitbar_handle);
            if strcmp(DATA.flag, 'hrv_time') || strcmp(DATA.flag, 'hrv_fragmentation')
                if strcmp(DATA.flag, 'hrv_time')
                    clear_time_data();
                end
                if strcmp(DATA.flag, 'hrv_fragmentation')
                    clear_fragmentation_data();
                end
                updateTimeStatistics();
                old_calcFrequencyStatistics();
                plot_frequency_statistics_results();
                old_calcNolinearStatistics();
                plot_nonlinear_statistics_results();
            elseif strcmp(DATA.flag, 'hrv_freq')
                clear_frequency_data();
                old_calcNolinearStatistics();
                plot_nonlinear_statistics_results();
            elseif strcmp(DATA.flag, 'hrv_nonlinear')
                clear_nonlinear_data();
            end
            rethrow(e);
        end
    end
%%
%     function GetPlotSignal()
%         if ~isempty(DATA.rri)
%             getSignal();
%             getFilteredSignal();
%             plotSignal();
%         end
%     end
%%
%     function run_after_mammal_change(index_selected)
%         createConfigParametersInterface();
%         try
%             if(isfield(DATA, 'rri') && ~isempty(DATA.rri))
%                 FiltSignal();
%                 CalcPlotSignalStat();
%             end
%             DATA.mammal_index = index_selected;
%         catch e
%             errordlg(['Mammal_popupmenu_Callback Error: ' e.message], 'Input Error');
%             %             GUI.Mammal_popupmenu.Value = DATA.mammal_index;
%             %             rhrv_load_defaults(DATA.mammals{DATA.mammal_index});
%             %             createConfigParametersInterface();
%             if strcmp(DATA.flag, 'hrv_time')
%                 clear_time_data();
%             end
%             if strcmp(DATA.flag, 'hrv_fragmentation')
%                 clear_fragmentation_data();
%             end
%             if strcmp(DATA.flag, 'hrv_time') || strcmp(DATA.flag, 'hrv_fragmentation')
%                 updateTimeStatistics();
%             end
%
%             if strcmp(DATA.flag, 'hrv_freq')
%                 clear_frequency_data();
%             end
%             if strcmp(DATA.flag, 'hrv_nonlinear')
%                 clear_nonlinear_data();
%             end
%             updateStatisticsTable();
%         end
%     end
%%
    function Mammal_popupmenu_Callback( ~, ~ )
        
        set_defaults_path();
        
        %persistent configDirectory;
        index_selected = get(GUI.Mammal_popupmenu,'Value');
        if index_selected == 5
            %             if isempty(configDirectory)
            %                 configDirectory = [basepath filesep 'Config'];
            %             end
            [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
            if ~isequal(Config_FileName, 0)
                params_filename = fullfile(PathName, Config_FileName);
                [pathstr, name, ~] = fileparts(params_filename);
                rhrv_load_defaults([pathstr filesep name]);
                DIRS.configDirectory = PathName;
            else % Cancel by user
                GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                return;
            end
        else
            % Load user-specified default parameters
            rhrv_load_defaults(DATA.mammals{index_selected});
        end
        %run_after_mammal_change(index_selected);
        createConfigParametersInterface();
        reset_plot();
        DATA.mammal_index = index_selected;
    end
%%
    function Integration_popupmenu_Callback( ~, ~ )
        items = get(GUI.Integration_popupmenu, 'String');
        index_selected = get(GUI.Integration_popupmenu,'Value');
        DATA.Integration = items{index_selected};
    end

%%
%     function enable_disable_filtering_params()
%
%         if DATA.filter_index == 1 % Lowpass
%             cellfun(@(x) set(x, 'Enable', 'on'), DATA.LowPassFilteringFields);
%             cellfun(@(x) set(x, 'Enable', 'off'), DATA.PoincareFilteringFields);
%         elseif DATA.filter_index == 2 % Poincare
%             cellfun(@(x) set(x, 'Enable', 'off'), DATA.LowPassFilteringFields);
%             cellfun(@(x) set(x, 'Enable', 'on'), DATA.PoincareFilteringFields);
%         elseif DATA.filter_index == 3 % Combined Filters
%             cellfun(@(x) set(x, 'Enable', 'on'), DATA.LowPassFilteringFields);
%             cellfun(@(x) set(x, 'Enable', 'on'), DATA.PoincareFilteringFields);
%         elseif DATA.filter_index == 4 % No Filtering
%             cellfun(@(x) set(x, 'Enable', 'off'), DATA.LowPassFilteringFields);
%             cellfun(@(x) set(x, 'Enable', 'off'), DATA.PoincareFilteringFields);
%         end
%     end
%%
    function Filtering_popupmenu_Callback( ~, ~ )
        items = get(GUI.Filtering_popupmenu, 'String');
        index_selected = get(GUI.Filtering_popupmenu,'Value');
        Filter = items{index_selected};
        
        try
            set_filters(Filter);
            if(isfield(DATA, 'rri') && ~isempty(DATA.rri) )
                FiltSignal();
                %CalcPlotSignalStat();
                %cla(GUI.RawDataAxes);
                clear_statistics_plots();
                clearStatTables();
                %plotRawData();
                %setXAxesLim();
                %setYAxesLim();
                plotFilteredData();
                %plotDataQuality();
                %plotMultipleWindows();
                calcStatistics();
            end
            DATA.filter_index = index_selected;
        catch e
            errordlg(['Filtering_popupmenu_Callback Error: ' e.message], 'Input Error');
            %             GUI.Filtering_popupmenu.Value = DATA.filter_index;
            %             set_filters(items{DATA.filter_index});
            
            %             if strcmp(DATA.flag, 'hrv_time')
            %                 clear_time_data();
            %             end
            %             if strcmp(DATA.flag, 'hrv_fragmentation')
            %                 clear_fragmentation_data();
            %             end
            %             if strcmp(DATA.flag, 'hrv_time') || strcmp(DATA.flag, 'hrv_fragmentation')
            %                 updateTimeStatistics();
            %             end
            %
            %             if strcmp(DATA.flag, 'hrv_freq')
            %                 clear_frequency_data();
            %             end
            %             if strcmp(DATA.flag, 'hrv_nonlinear')
            %                 clear_nonlinear_data();
            %             end
            %             updateStatisticsTable();
        end
    end
%%
    function DefaultMethod_popupmenu_Callback( ~, ~ )
        DATA.default_method_index = get(GUI.DefaultMethod_popupmenu, 'Value');
        %         setFrequencyParametersTableMethodRowName();
        %         updateStatisticsTable();
        
        %updateMainStatisticsTable_FrequencyPart();
        [StatRowsNames, StatData] = setFrequencyMethodData();
        updateMainStatisticsTable(DATA.timeStatPartRowNumber, StatRowsNames, StatData);
    end
%%
    function [StatRowsNames, StatData] = setFrequencyMethodData()
        if DATA.default_method_index == 1 % Lomb
            StatRowsNames = DATA.FrStat.LombWindowsData.RowsNames;
            StatData = DATA.FrStat.LombWindowsData.Data;
        elseif DATA.default_method_index == 3 % AR
            StatRowsNames = DATA.FrStat.ArWindowsData.RowsNames;
            StatData = DATA.FrStat.ArWindowsData.Data;
        elseif DATA.default_method_index == 2 % Welch
            StatRowsNames = DATA.FrStat.WelchWindowsData.RowsNames;
            StatData = DATA.FrStat.WelchWindowsData.Data;
        end
    end
%%
%     function updateMainStatisticsTable_NonLinearPart()
%         prevPartRowNumber = DATA.frequencyStatPartRowNumber;
%         [rn, ~] = size(DATA.NonLinStat.RowsNames);
%         GUI.StatisticsTable.RowName(prevPartRowNumber + 1 : prevPartRowNumber + rn) = DATA.NonLinStat.RowsNames;
%         [rn, ~] = size(DATA.NonLinStat.Data);
%         GUI.StatisticsTable.Data(prevPartRowNumber + 1 : prevPartRowNumber + rn, :) = DATA.NonLinStat.Data;
%     end
%%
    function updateMainStatisticsTable(prevPartRowNumber, RowsNames, Data)
        [rowNumber, colNumber] = size(Data);
        GUI.StatisticsTable.RowName(prevPartRowNumber + 1 : prevPartRowNumber + rowNumber) = RowsNames;
        GUI.StatisticsTable.Data(prevPartRowNumber + 1 : prevPartRowNumber + rowNumber, 1 : colNumber) = Data;
    end
%%
%     function setFrequencyParametersTableMethodRowName()
%         if DATA.default_method_index == 1 % Lomb
%             GUI.FrequencyParametersTableMethodRowName = DATA.fd_LombRowsNames;
%             GUI.FrequencyParametersTableData = [DATA.fd_lombDescriptions DATA.fd_lombData];
%         elseif DATA.default_method_index == 3 % AR
%             GUI.FrequencyParametersTableMethodRowName = DATA.fd_ArRowsNames;
%             GUI.FrequencyParametersTableData = [DATA.fd_ArDescriptions DATA.fd_arData];
%         elseif DATA.default_method_index == 2 % Welch
%             GUI.FrequencyParametersTableMethodRowName = DATA.fd_WelchRowsNames;
%             GUI.FrequencyParametersTableData = [DATA.fd_WelchDescriptions DATA.fd_welchData];
%         end
%     end
%%
    function clear_time_data()
        DATA.hrv_td = table;
        DATA.pd_time = struct([]);
        
        GUI.TimeParametersTableData = [];
        GUI.TimeParametersTable.RowName = [];
        GUI.TimeParametersTable.Data = [];
        clear_time_statistics_results();
    end
%%
    function clear_fragmentation_data()
        DATA.hrv_frag = table;
        GUI.FragParametersTableData = [];
        GUI.FragParametersTable.RowName=[];
        GUI.FragParametersTable.Data = [];
    end
%%
    function clear_frequency_data()
        DATA.hrv_fd = table;
        DATA.pd_freq = struct([]);
        
        DATA.hrv_fd_lomb = table;
        DATA.hrv_fd_ar = table;
        DATA.hrv_fd_welch = table;
        
        GUI.FrequencyParametersTableData = [];
        GUI.FrequencyParametersTable.RowName = [];
        GUI.FrequencyParametersTableMethodRowName = [];
        GUI.FrequencyParametersTable.Data = [];
        
        clear_frequency_statistics_results();
    end
%%
    function clear_nonlinear_data()
        DATA.hrv_nl = table;
        DATA.pd_nl = struct([]);
        
        GUI.NonLinearTableData = [];
        GUI.NonLinearTable.RowName = [];
        GUI.NonLinearTable.Data = [];
        
        clear_nonlinear_statistics_results();
    end

%%
    function set_filters(Filter)
        if strcmp(Filter, 'No Filtering') % No Filtering
            DATA.filter_quotient = false;
            DATA.filter_lowpass = false;
            DATA.filter_range = false;
        elseif strcmp(Filter, 'LowPass') % LowPass
            DATA.filter_quotient = false;
            DATA.filter_lowpass = true;
            DATA.filter_range = false;
        elseif strcmp(Filter, 'Range') % Range
            DATA.filter_quotient = false;
            DATA.filter_lowpass = false;
            DATA.filter_range = true;
        elseif strcmp(Filter, 'Quotient') % Quotient
            DATA.filter_quotient = true;
            DATA.filter_lowpass = false;
            DATA.filter_range = false;
        elseif strcmp(Filter, 'Combined Filters') % Combined Filters
            DATA.filter_quotient = true;
            DATA.filter_lowpass = true;
            DATA.filter_range = true;
        end
    end

%%
    function FirstSecond_Callback ( ~, ~ )
        if ~isempty(DATA.rri)
            screen_value = get(GUI.FirstSecond, 'String');
            [firstSecond2Show, isInputNumeric]  = calcDurationInSeconds(GUI.FirstSecond, screen_value, DATA.firstSecond2Show);
            if isInputNumeric
                if firstSecond2Show < 0 || firstSecond2Show > DATA.maxSignalLength - DATA.MyWindowSize  % + 1
                    set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
                    errordlg('The first second value must be grater than 0 and less then signal length!', 'Input Error');
                else
                    set(GUI.RawDataSlider, 'Value', firstSecond2Show);
                    DATA.firstSecond2Show = firstSecond2Show;
                    %GetPlotSignal();
                    %plotRawData();
                    setXAxesLim();
                end
            end
        end
    end

%%
    function Filt_FirstSecond_Callback ( ~, ~ )
        if ~isempty(DATA.rri)
            Filt_FirstSecond2Show = get(GUI.Filt_FirstSecond, 'String');
            [Filt_FirstSecond2Show, isInputNumeric]  = calcDurationInSeconds(GUI.Filt_FirstSecond, Filt_FirstSecond2Show, DATA.BatchParams.startTime);
            if isInputNumeric
                if Filt_FirstSecond2Show < 0 || Filt_FirstSecond2Show > DATA.Filt_MaxSignalLength - DATA.BatchParams.windowLength % + 1
                    set(GUI.Filt_FirstSecond, 'String', calcDuration(DATA.BatchParams.startTime, 0));
                    errordlg('The filt first second value must be grater than 0 and less then signal length!', 'Input Error');
                else
                    set(GUI.Filt_RawDataSlider, 'Value', Filt_FirstSecond2Show);
                    %DATA.Filt_FirstSecond2Show = Filt_FirstSecond2Show;
                    DATA.BatchParams.startTime = Filt_FirstSecond2Show;
                    DATA.BatchParams.endTime = Filt_FirstSecond2Show + DATA.BatchParams.windowLength;
                    set(GUI.batch_startTime, 'String', calcDuration(DATA.BatchParams.startTime, 0));
                    set(GUI.batch_endTime, 'String', calcDuration(DATA.BatchParams.endTime, 0));
                    clear_statistics_plots();
                    clearStatTables();
                    calcBatchWinNum();
                    plotFilteredData();
                    plotMultipleWindows();                    
                    %GetPlotSignal();
                    calcStatistics();
                end
            end
        end
    end
%%
    function signalDuration = calcDuration(varargin)
        
        signal_length = double(varargin{1});
        if length(varargin) == 2
            need_ms = varargin{2};
        else
            need_ms = 1;
        end
        % Duration of signal
        duration_h  = mod(floor(signal_length / 3600), 60);
        duration_m  = mod(floor(signal_length / 60), 60);
        duration_s  = mod(floor(signal_length), 60);
        duration_ms = floor(mod(signal_length, 1)*1000);
        if need_ms
            signalDuration = sprintf('%02d:%02d:%02d.%03d', duration_h, duration_m, duration_s, duration_ms);
        else
            signalDuration = sprintf('%02d:%02d:%02d', duration_h, duration_m, duration_s);
        end
    end
%%
    function [signalDurationInSec, isInputNumeric]  = calcDurationInSeconds(GUIFiled, NewFieldValue, OldFieldValue)
        duration = sscanf(NewFieldValue, '%d:%d:%d.%d');
        
        isInputNumeric = true;
        
        if length(duration) == 1 && duration(1) > 0
            signalDuration = calcDuration(duration(1), 0);
            set(GUIFiled,'String', signalDuration);
            signalDurationInSec = duration(1);
        elseif length(duration) == 3 && duration(1) >= 0 && duration(2) >= 0 && duration(3) >= 0
            signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3);
        elseif length(duration) == 4 && duration(1) >= 0 && duration(2) >= 0 && duration(3) >= 0 && duration(4) >= 0
            signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3)+ duration(4)/1000;
        else
            set(GUIFiled, 'String', calcDuration(OldFieldValue, 0));
            warndlg('Please, check your input');
            isInputNumeric = false;
            signalDurationInSec = [];
        end
        
        %         if signalDurationInSec == 0
        %             set(GUIFiled, 'String', calcDuration(OldFieldValue, 0));
        %             warndlg('Please, check your input');
        %             isInputNumeric = false;
        %             signalDurationInSec = [];
        %         end
        
        
        %         if isempty(duration) || duration(1) < 0 || duration(2) < 0 || duration(3) < 0 || length(duration) == 2 || length(duration) > 3
        %             set(GUIFiled,'String', calcDuration(OldFieldValue, 0));
        %             warndlg('Please, check your input');
        %             isInputNumeric = false;
        %             signalDurationInSec = [];
        %         elseif length(duration) == 1
        %             signalDuration = calcDuration(duration(1), 0);
        %             set(GUIFiled,'String', signalDuration);
        %             signalDurationInSec = duration(1);
        %         else
        %             signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3);
        %         end
    end
%%
    function cancel_button_Callback( ~, ~ )
        delete( GUI.SaveFiguresWindow );
    end
%%
    function dir_button_Callback( ~, ~ )
        %         if isempty(ExportResultsDirectory)
        %             ExportResultsDirectory = basepath;
        %         end
        set_defaults_path();
        
        [fig_name, fig_path, FilterIndex] = uiputfile({'*.fig','MATLAB Figure (*.fig)';...
            '*.bmp','Bitmap file (*.bmp)';...
            '*.eps','EPS file (*.eps)';...
            '*.emf','Enhanced metafile (*.emf)';...
            '*.jpg','JPEG image (*.jpg)';...
            '*.pcx','Paintbrush 24-bit file (*.pcx)';...
            '*.pbm','Portable Bitmap file (*.pbm)';...
            '*.pdf','Portable Document Format (*.pdf)';...
            '*.pgm','Portable Graymap file (*.pgm)';...
            '*.png','Portable Network Grafics file (*.png)';...
            '*.ppm','Portable Pixmap file (*.ppm)';...
            '*.svg','Scalable Vector Graphics file (*.svg)';...
            '*.tif','TIFF image (*.tif)';...
            '*.tif','TIFF no compression image (*.tif)'},'Choose Figures file Name', [DIRS.ExportResultsDirectory, filesep, DATA.DataFileName ]);
        
        if ~isequal(fig_path, 0)
            DIRS.ExportResultsDirectory = fig_path;
            GUI.path_edit.String = [fig_path, fig_name];
            
            [fig_path, fig_name, fig_ext] = fileparts(get(GUI.path_edit, 'String'));
            
            if ~isempty(fig_path) && ~isempty(fig_name)
                set(GUI.Formats_popupmenu, 'Value', FilterIndex);
            end
        end
    end
%%
    function onSaveFiguresAsFile( ~, ~ )
        
        %         if isempty(ExportResultsDirectory)
        %             ExportResultsDirectory = basepath;
        %         end
        set_defaults_path();
        
        FiguresNames = {'NN Interval Distribution'; 'Power Spectral Density'; 'Beta'; 'DFA'; 'MSE'; 'Poincare Ellipse'};
        
        if ~isfield(DATA_Fig, 'export_figures')
            DATA_Fig.export_figures = [1 1 1 1 1 1];
        end
        if ~isfield(DATA_Fig, 'export_figures_formats_index')
            DATA_Fig.export_figures_formats_index = DATA.formats_index;
        end
        
        GUI.SaveFiguresWindow = figure( ...
            'Name', 'Export Figures Options', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [700, 300, 800, 400]);
        
        mainSaveFigurestLayout = uix.VBox('Parent',GUI.SaveFiguresWindow, 'Spacing', 3);
        figures_panel = uix.Panel( 'Parent', mainSaveFigurestLayout, 'Padding', 7, 'Title', 'Select figures to save:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        figures_box = uix.VButtonBox('Parent', figures_panel, 'Spacing', 2, 'HorizontalAlignment', 'left', 'ButtonSize', [200 25]);
        
        for i = 1 : 6
            uicontrol( 'Style', 'checkbox', 'Parent', figures_box, 'Callback', {@figures_checkbox_Callback, i}, 'FontSize', DATA.BigFontSize, ...
                'Tag', ['Fig' num2str(i)], 'String', FiguresNames{i}, 'FontName', 'Calibri', 'Value', DATA_Fig.export_figures(i));
        end
        
        main_path_panel = uix.Panel( 'Parent', mainSaveFigurestLayout, 'Padding', 7, 'Title', 'Choose figures path:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        main_path_box = uix.VBox('Parent', main_path_panel, 'Spacing', 3);
        path_box = uix.HBox('Parent', main_path_box, 'Spacing', 3);
        GUI.path_edit = uicontrol( 'Style', 'edit', 'Parent', path_box, ...
            'String', [DIRS.ExportResultsDirectory, filesep, DATA.DataFileName '.' DATA.FiguresFormats{DATA_Fig.export_figures_formats_index}], ...
            'FontSize', DATA.BigFontSize, 'FontName', 'Calibri', 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', path_box );
        set( path_box, 'Widths', [-80 -10 ] );
        dir_button_Box = uix.HButtonBox('Parent', main_path_box, 'Spacing', 3, 'HorizontalAlignment', 'left', 'ButtonSize', [100 25]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', dir_button_Box, 'Callback', @dir_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Change Path', 'FontName', 'Calibri');
        set( main_path_box, 'Heights', [-30 -70] );
        
        main_formats_panel = uix.Panel( 'Parent', mainSaveFigurestLayout, 'Padding', 7, 'Title', 'Choose figures format:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        format_box = uix.HBox('Parent', main_formats_panel, 'Spacing', 3);
        GUI.Formats_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', format_box, 'Callback', @Formats_popupmenu_Callback, 'FontSize', DATA.BigFontSize, 'FontName', 'Calibri');
        GUI.Formats_popupmenu.String = DATA.FiguresFormats;
        set(GUI.Formats_popupmenu, 'Value', DATA_Fig.export_figures_formats_index);
        uix.Empty( 'Parent', format_box );
        set( format_box, 'Widths', [-20 -80 ] );
        
        CommandsButtons_Box = uix.HButtonBox('Parent', mainSaveFigurestLayout, 'Spacing', 3, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'ButtonSize', [125 30]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @save_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Export Figures', 'FontName', 'Calibri');
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @cancel_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Cancel', 'FontName', 'Calibri');
        
        set( mainSaveFigurestLayout, 'Heights', [-70 -45 -25 -20] );
    end
%%
    function figures_checkbox_Callback( src, ~, param_name )
        DATA_Fig.export_figures(param_name) = get(src, 'Value');
    end
%%
    function Formats_popupmenu_Callback( ~, ~ )
        index_selected = get(GUI.Formats_popupmenu, 'Value');
        DATA.formats_index = index_selected;
        
        [fig_path, fig_name, fig_ext] = fileparts(get(GUI.path_edit, 'String'));
        
        if ~isempty(fig_path) && ~isempty(fig_name)
            GUI.path_edit.String = [fig_path, filesep, fig_name '.' DATA.FiguresFormats{index_selected}];
        end
    end
%%
    function save_button_Callback( ~, ~ )
        
        [fig_path, fig_name, fig_ext] = fileparts(get(GUI.path_edit, 'String'));
        
        if ~isempty(fig_path) && ~isempty(fig_name) && ~isempty(fig_ext)
            
            DATA_Fig.export_figures_formats_index = DATA.formats_index;
            
            DIRS.ExportResultsDirectory = fig_path;
            
            ext = fig_ext(2:end);
            
            if strcmpi(ext, 'pcx')
                ext = 'pcx24b';
            elseif strcmpi(ext, 'emf')
                ext = 'meta';
            elseif strcmpi(ext, 'jpg')
                ext = 'jpeg';
            elseif strcmpi(ext, 'tif')
                ext = 'tiff';
            elseif strcmpi(ext, 'tiff')
                ext = 'tiffn';
            end
            
            export_path_name = [fig_path filesep fig_name];
            
            if ~strcmpi(ext, 'fig')
                
                if ~isempty(DATA.pd_time) && DATA_Fig.export_figures(1)
                    af = figure;
                    set(af, 'Visible', 'off')
                    plot_hrv_time_hist(gca, DATA.pd_time, 'clear', true);
                    fig_print( af, [export_path_name, '_NN_Interval_Distribution'], 'output_format', ext);
                    close(af);
                end
                
                if ~isempty(DATA.pd_freq)
                    if DATA_Fig.export_figures(2)
                        af = figure;
                        set(af, 'Visible', 'off')
                        plot_hrv_freq_spectrum(gca, DATA.pd_freq, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
                        fig_print( af, [export_path_name, '_Power_Spectral_Density'], 'output_format', ext);
                        close(af);
                    end
                    if DATA_Fig.export_figures(3)
                        af = figure;
                        set(af, 'Visible', 'off')
                        plot_hrv_freq_beta(gca, DATA.pd_freq);
                        fig_print( af, [export_path_name, '_Beta'], 'output_format', ext);
                        close(af);
                    end
                end
                
                if ~isempty(DATA.pd_nl)
                    if DATA_Fig.export_figures(4)
                        af = figure;
                        set(af, 'Visible', 'off')
                        plot_dfa_fn(gca, DATA.pd_nl.dfa);
                        fig_print( af, [export_path_name, '_DFA'], 'output_format', ext);
                        close(af);
                    end
                    if DATA_Fig.export_figures(5)
                        af = figure;
                        set(af, 'Visible', 'off')
                        plot_mse(gca, DATA.pd_nl.mse);
                        fig_print( af, [export_path_name, '_MSE'], 'output_format', ext);
                        close(af);
                    end
                    if DATA_Fig.export_figures(6)
                        af = figure;
                        set(af, 'Visible', 'off')
                        plot_poincare_ellipse(gca, DATA.pd_nl.poincare);
                        fig_print( af, [export_path_name, '_Poincare_Ellipse'], 'output_format', ext);
                        close(af);
                    end
                end
            elseif strcmpi(ext, 'fig')
                if ~isempty(DATA.pd_time) && DATA_Fig.export_figures(1)
                    af = figure;
                    set(af, 'Name', [fig_name, '_NN_Interval_Distribution'], 'NumberTitle', 'off');
                    plot_hrv_time_hist(gca, DATA.pd_time, 'clear', true);
                    savefig(af, [export_path_name, '_NN_Interval_Distribution'], 'compact');
                    close(af);
                end
                if ~isempty(DATA.pd_freq)
                    if DATA_Fig.export_figures(2)
                        af = figure;
                        set(af, 'Name', [fig_name, '_Power_Spectral_Density'], 'NumberTitle', 'off');
                        plot_hrv_freq_spectrum(gca, DATA.pd_freq, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
                        savefig(af, [export_path_name, '_Power_Spectral_Density'], 'compact');
                        close(af);
                    end
                    if DATA_Fig.export_figures(3)
                        af = figure;
                        set(af, 'Name', [fig_name, '_Beta'], 'NumberTitle', 'off');
                        plot_hrv_freq_beta(gca, DATA.pd_freq);
                        savefig(af, [export_path_name, '_Beta'], 'compact');
                        close(af);
                    end
                end
                if ~isempty(DATA.pd_nl)
                    if DATA_Fig.export_figures(4)
                        af = figure;
                        set(af, 'Name', [fig_name, '_DFA'], 'NumberTitle', 'off');
                        plot_dfa_fn(gca, DATA.pd_nl.dfa);
                        savefig(af, [export_path_name, '_DFA'], 'compact');
                        close(af);
                    end
                    if DATA_Fig.export_figures(5)
                        af = figure;
                        set(af, 'Name', [fig_name, '_MSE'], 'NumberTitle', 'off');
                        plot_mse(gca, DATA.pd_nl.mse);
                        savefig(af, [export_path_name, '_MSE'], 'compact');
                        close(af);
                    end
                    if DATA_Fig.export_figures(6)
                        af = figure;
                        set(af, 'Name', [fig_name, '_Poincare_Ellipse'], 'NumberTitle', 'off');
                        plot_poincare_ellipse(gca, DATA.pd_nl.poincare);
                        savefig(af, [export_path_name, '_Poincare_Ellipse'], 'compact');
                        close(af);
                    end
                end
            end
            delete( GUI.SaveFiguresWindow );
        else
            errordlg('Please enter valid path for export figures', 'Input Error');
        end
    end
%%
    function onSaveResultsAsFile( ~, ~ )
        
        %         persistent statDirectory;
        %
        %         if isempty(statDirectory)
        %             statDirectory = basepath;
        %         end
        
        set_defaults_path();
        
        [filename, results_folder_name, FilterIndex] = uiputfile({'*.txt','Text Files (*.txt)'; '*.mat','MAT-files (*.mat)';},'Choose Result File Name', [DIRS.ExportResultsDirectory, filesep, DATA.DataFileName ]);
        
        if ~isequal(results_folder_name, 0)
            
            DIRS.ExportResultsDirectory = results_folder_name;
            
            [~, filename, ~] = fileparts(filename);
            
            if FilterIndex == 1
                ext = '.txt';
            else
                ext = '.mat';
            end
            
            full_file_name_hea = fullfile(results_folder_name, [filename '_hea.txt']);
            full_file_name_hrv = fullfile(results_folder_name, [filename '_hrv' ext]);
            full_file_name_psd = fullfile(results_folder_name, [filename '_psd' ext]);
            
            button = 'Yes';
            
            if exist(full_file_name_hrv, 'file')
                button = questdlg([full_file_name_hrv ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
            end
            
            if strcmp(button, 'Yes')
                
                AllRowsNames = [DATA.TimeStat.RowsNames; DATA.FrStat.WelchWindowsData.RowsNames; DATA.FrStat.LombWindowsData.RowsNames; DATA.FrStat.ArWindowsData.RowsNames; DATA.NonLinStat.RowsNames];
                statistics_params = [DATA.TimeStat.Data; DATA.FrStat.WelchWindowsData.Data; DATA.FrStat.LombWindowsData.Data; DATA.FrStat.ArWindowsData.Data; DATA.NonLinStat.Data];
                
                column_names = {'Description'};
                for i = 1 : DATA.BatchParams.winNum
                    column_names = cat(1, column_names, ['W' num2str(i)]);
                end


                if FilterIndex == 1
                    header_fileID = fopen(full_file_name_hea, 'w');
%                     hrv_fileID = fopen(full_file_name_hrv, 'w');
                    
                    fprintf(header_fileID, '#header\r\n');
                    fprintf(header_fileID, 'Record name: %s\r\n\r\n', DATA.DataFileName);
                    fprintf(header_fileID, 'Mammal: %s\r\n', DATA.mammals{ DATA.mammal_index});
                    fprintf(header_fileID, 'Integration level: %s\r\n', DATA.Integration);
                    fprintf(header_fileID, 'Filtering: %s\r\n', DATA.Filters{DATA.filter_index});
                    fprintf(header_fileID, 'Window start: %s\r\n', calcDuration(DATA.BatchParams.startTime));
                    fprintf(header_fileID, 'Window end: %s\r\n', calcDuration(DATA.BatchParams.endTime));
                    fprintf(header_fileID, 'Window length: %s\r\n', calcDuration(DATA.BatchParams.windowLength));
                    fprintf(header_fileID, 'Overlap: %s\r\n', num2str(DATA.BatchParams.overlap));
                    fprintf(header_fileID, 'Windows number: %s\r\n', num2str(DATA.BatchParams.winNum));
                    fprintf(header_fileID, 'Number of mammals: 1\r\n');
                    
                    fclose(header_fileID);
                    
                    max_length_rows_names = max(cellfun(@(x) strlength(x), AllRowsNames));
                    padded_rows_names = cellfun(@(x) [pad(x, max_length_rows_names) ':'], AllRowsNames, 'UniformOutput', false );
                    
                    max_length_descr = max(cellfun(@(x) strlength(x), statistics_params(:, 1)));
                    statistics_params(:, 1) = cellfun(@(x) pad(x, max_length_descr), statistics_params(:, 1), 'UniformOutput', false );                                                                            
                    
                    statisticsTable = cell2table(statistics_params, 'RowNames', padded_rows_names); %, 'VariableNames', column_names);                                        
                    statisticsTable.Properties.DimensionNames(1) = {'Measures'};
                    writetable(statisticsTable, full_file_name_hrv, 'Delimiter', '\t', 'WriteRowNames', true, 'WriteVariableNames', false);                                  
                                        
                    psd_fileID = fopen(full_file_name_psd, 'w');                    
                    fprintf(psd_fileID, 'Frequency\tPSD_AR\t\tPSD_Welch\tPSD_Lomb\r\n');                    
                    dlmwrite(full_file_name_psd, [DATA.pd_freq.f_axis DATA.pd_freq.pxx_ar DATA.pd_freq.pxx_welch DATA.pd_freq.pxx_lomb], ...
                             'precision', '%.5f\t\n', 'delimiter', '\t', 'newline', 'pc', 'roffset', 2, '-append');                                             
                    fclose(psd_fileID);
                    
%                     fprintf(hrv_fileID, '#HRV Statistics\r\n');
%                     fprintf(hrv_fileID, '#Record name: %s\r\n\r\n', DATA.DataFileName);
%                     
%                     %fprintf(hrv_fileID, '\r\n*HRV Time\r\n');
%                     param_number = length(DATA.timeData);
%                     for i = 1 : param_number
%                         fprintf(hrv_fileID, '%s, %s\r\n', DATA.timeRowsNames{i, 1}, DATA.timeData{i, 1});
%                     end
%                     
%                     param_number = length(DATA.fragData);
%                     for i = 1 : param_number
%                         fprintf(hrv_fileID, '%s, %s\r\n', DATA.fragRowsNames{i, 1}, DATA.fragData{i, 1});
%                     end
%                     
%                     %fprintf(hrv_fileID, '\r\n\n*HRV Frequency\r\n');
%                     param_number = length(DATA.fd_lombData);
%                     %fprintf(hrv_fileID, '\r\n\n^Lomb Method\r\n');
%                     for i = 1 : param_number
%                         fprintf(hrv_fileID, '%s, %s\r\n', DATA.fd_LombRowsNames{i, 1}, DATA.fd_lombData{i, 1});
%                     end
%                     %fprintf(hrv_fileID, '\r\n\n^Ar Method\r\n');
%                     for i = 1 : param_number
%                         fprintf(hrv_fileID, '%s, %s\r\n', DATA.fd_ArRowsNames{i, 1}, DATA.fd_arData{i, 1});
%                     end
%                     %fprintf(hrv_fileID, '\r\n\n^Welch Method\r\n');
%                     for i = 1 : param_number
%                         fprintf(hrv_fileID, '%s, %s\r\n', DATA.fd_WelchRowsNames{i, 1}, DATA.fd_welchData{i, 1});
%                     end
%                     
%                     %fprintf(hrv_fileID, '\r\n\n*HRV Non Linear\r\n');
%                     param_number = length(DATA.nonlinData);
%                     for i = 1 : param_number
%                         fprintf(hrv_fileID, '%s, %s\r\n', DATA.nonlinRowsNames{i, 1}, DATA.nonlinData{i, 1});
%                     end
%                     fclose(hrv_fileID);
                else
                    RecordName = DATA.DataFileName;
                    Mammal = DATA.mammals{ DATA.mammal_index};
                    IntegrationLevel = DATA.Integration;
                    Filtering = DATA.Filters{DATA.filter_index};
                    WindowStart = calcDuration(DATA.BatchParams.startTime);
                    WindowEnd = calcDuration(DATA.BatchParams.endTime);
                    WindowLength = calcDuration(DATA.BatchParams.windowLength);
                    Overlap = DATA.BatchParams.overlap;
                    WindowNumber = DATA.BatchParams.winNum;
                    MammalsNumber = 1;
                    
                    Frequency = DATA.pd_freq.f_axis;
                    PSD_AR = DATA.pd_freq.pxx_ar;
                    PSD_Welch = DATA.pd_freq.pxx_welch;
                    PSD_Lomb = DATA.pd_freq.pxx_lomb;
                    
                    statisticsTable = cell2table(statistics_params, 'RowNames', AllRowsNames, 'VariableNames', column_names);                                 
                    statisticsTable.Properties.DimensionNames(1) = {'Measures'};
                    
%                     TimeDomainData = DATA.hrv_td;
%                     FrequencyDomainData = DATA.hrv_fd;
%                     NonLinearData = DATA.hrv_nl;
                    save(full_file_name_hrv, 'RecordName', 'Mammal', 'IntegrationLevel', 'Filtering', 'WindowStart', 'WindowEnd', 'WindowLength', 'Overlap', 'WindowNumber', 'MammalsNumber',...
                        'statisticsTable');
                    save(full_file_name_psd, 'Frequency', 'PSD_AR', 'PSD_Welch', 'PSD_Lomb');
                end
            end
        end
    end

%%
    function onPhysioZooHome( ~, ~ )
        url = 'http://www.physiozoo.com/';
        web(url,'-browser')
    end
%%
    function onAbout( ~, ~ )
        
        GUI.AboutWindow = figure( ...
            'Name', 'HRV About', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [700, 300, 400, 400]);
        
        GUI.mainAboutLayout = uix.VBox('Parent', GUI.AboutWindow, 'Spacing', 3);
        GUI.ImageAxes = axes('Parent', GUI.mainAboutLayout, 'ActivePositionProperty', 'Position');
        
        logoImage = imread('D:\PhysioZoo\Physio Zoo Logo Dina 1.jpg');
        imagesc(logoImage, 'Parent', GUI.ImageAxes);
        set( GUI.ImageAxes, 'xticklabel', [], 'yticklabel', [] );
        set(GUI.ImageAxes,'handlevisibility','off','visible','off')
    end
%%
    function waitbar_handle = update_statistics(param_category)
        if strcmp(param_category, 'filtrr')
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            FiltSignal();
            %CalcPlotSignalStat();
            clear_statistics_plots();
            clearStatTables();
            plotFilteredData();
            calcStatistics();
            close(waitbar_handle);
        elseif strcmp(param_category, 'hrv_time')
            %             old_calcTimeStatistics();
            %             plot_time_statistics_results();
            %             clear_time_statistics_results();
            %             clearStatTables();
            %clear_time_data();
            %clear_fragmentation_data();
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            calcTimeStatistics(waitbar_handle);
            close(waitbar_handle);
        elseif strcmp(param_category, 'hrv_freq') % strcmp(param_category, 'hrv_nl') ||
            %             old_calcFrequencyStatistics();
            %             plot_frequency_statistics_results();
            %             clear_frequency_statistics_results();
            %             clearStatTables();
            %clear_frequency_data();
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            calcFrequencyStatistics(waitbar_handle);
            close(waitbar_handle);
        elseif strcmp(param_category, 'dfa') || strcmp(param_category, 'mse')
            %             old_calcNolinearStatistics();
            %             plot_nonlinear_statistics_results();
            %             clear_nonlinear_statistics_results();
            %             clearStatTables();
            %clear_nonlinear_data();
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            calcNonlinearStatistics(waitbar_handle);
            close(waitbar_handle);
        end
    end
%%
    function set_config_Callback(src, ~, param_name)
        
        cp_param_array = [];
        do_couple = false;
        param_category = strsplit(param_name, '.');
        %DATA.flag = 0;
        
        %         if strcmp(get(src, 'Style'), 'popupmenu')
        %             prev_default_method_index = DATA.default_method_index;
        %             DATA.default_method_index = get(src, 'Value');
        % %             methods_str = get(src, 'String');
        % %             value = methods_str{index_selected};
        %             screen_value = 0;
        %else
        min_suffix_ind = strfind(param_name, '.min');
        max_suffix_ind = strfind(param_name, '.max');
        
        screen_value = str2double(get(src, 'String'));
        prev_screen_value = get(src, 'UserData');
        
        if strcmp(param_name, 'hrv_freq.welch_overlap')
            if isnan(screen_value) || screen_value < 0 || screen_value >= 100
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
        elseif strcmp(param_name, 'filtrr.quotient.rr_max_change')
            if isnan(screen_value) || screen_value <= 0 || screen_value > 100
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
        elseif strcmp(param_name, 'filtrr.lowpass.win_threshold')
            if isnan(screen_value) || screen_value < 0 || screen_value > 100
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
        elseif strcmp(param_name, 'hrv_freq.window_minutes')
            if isnan(screen_value) || screen_value > double(DATA.maxSignalLength)/60 || screen_value < 0.5
                errordlg(['set_config_Callback error: ' 'The value must be greater than 30 sec and less than ' num2str(double(DATA.maxSignalLength)/60), ' sec!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
        elseif  isnan(screen_value) || ~(screen_value > 0)
            errordlg(['set_config_Callback error: ' 'This parameter must be numeric positive single value!'], 'Input Error');
            set(src, 'String', prev_screen_value);
            return;
        end
        
        if ~isempty(min_suffix_ind)
            param_name = param_name(1 : min_suffix_ind - 1);
            min_param_value = screen_value;
            prev_param_array = rhrv_get_default(param_name);
            max_param_value = prev_param_array.value(2);
            
            if min_param_value > max_param_value
                errordlg(['set_config_Callback error: ' 'This min value must be less that max value!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
            
            param_value = [min_param_value max_param_value];
            
            prev_param_value = prev_param_array.value(1);
            
            if strcmp(param_name, 'hrv_freq.lf_band')
                couple_name = 'hrv_freq.vlf_band';
                do_couple = true;
            elseif strcmp(param_name, 'hrv_freq.hf_band')
                couple_name = 'hrv_freq.lf_band';
                do_couple = true;
            end
            
            if do_couple
                cp_param_array = rhrv_get_default(couple_name);
                rhrv_set_default( couple_name, [cp_param_array.value(1) screen_value] );
                couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                set(findobj(couple_handle, 'Tag', [couple_name '.max']), 'String', num2str(screen_value));
            end
            
        elseif ~isempty(max_suffix_ind)
            param_name = param_name(1 : max_suffix_ind - 1);
            max_param_value = screen_value;
            prev_param_array = rhrv_get_default(param_name);
            min_param_value = prev_param_array.value(1);
            
            if max_param_value < min_param_value
                errordlg(['set_config_Callback error: ' 'This max value must be greater that min value!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
            
            param_value = [min_param_value max_param_value];
            
            prev_param_value = prev_param_array.value(2);
            
            if strcmp(param_name, 'hrv_freq.vlf_band')
                couple_name = 'hrv_freq.lf_band';
                do_couple = true;
            elseif strcmp(param_name, 'hrv_freq.lf_band')
                couple_name = 'hrv_freq.hf_band';
                do_couple = true;
            end
            if do_couple
                cp_param_array = rhrv_get_default(couple_name);
                rhrv_set_default( couple_name, [screen_value cp_param_array.value(2)] );
                couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                set(findobj(couple_handle, 'Tag', [couple_name '.min']), 'String', num2str(screen_value));
            end
        else
            param_value = screen_value;
            prev_param_array = rhrv_get_default(param_name);
            prev_param_value = prev_param_array.value;
        end
        rhrv_set_default( param_name, param_value );
        %end
        try
            update_statistics(param_category(1));
            set(src, 'UserData', screen_value);
        catch e
            errordlg(['set_config_Callback error: ' e.message], 'Input Error');
            %close(waitbar_handle);
            %             if strcmp(get(src, 'Style'), 'popupmenu')
            %                 DATA.default_method_index = prev_default_method_index;
            %                 set(src, 'Value', prev_default_method_index);
            %             else
            rhrv_set_default( param_name, prev_param_array );
            set(src, 'String', num2str(prev_param_value));
            
            if ~isempty(cp_param_array)
                rhrv_set_default( couple_name, cp_param_array );
                couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                if ~isempty(min_suffix_ind)
                    set(findobj(couple_handle, 'Tag', [couple_name '.max']), 'String', num2str(prev_param_value))
                elseif ~isempty(max_suffix_ind)
                    set(findobj(couple_handle, 'Tag', [couple_name '.min']), 'String', num2str(prev_param_value))
                end
            end
            %update_statistics(param_category(1));
            %end
        end
    end
%%
    function onLoadCustomConfigFile( ~, ~)
        %persistent configDirectory;
        %         if isempty(configDirectory)
        %             configDirectory = [basepath filesep 'Config'];
        %         end
        set_defaults_path();
        
        [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
        if ~isequal(Config_FileName, 0)
            params_filename = fullfile(PathName, Config_FileName);
            [pathstr, name, ~] = fileparts(params_filename);
            rhrv_load_defaults([pathstr filesep name]);
            DIRS.configDirectory = PathName;
            GUI.Mammal_popupmenu.Value = 5;
            %run_after_mammal_change(5);
            createConfigParametersInterface();
            reset_plot();
            DATA.mammal_index = 5;
        end
    end
%%
    function onSaveParamFile( ~, ~ )
        
        %         persistent paramDirectory;
        %
        %         if isempty(paramDirectory)
        %             paramDirectory = [basepath filesep 'Config'];
        %         end
        set_defaults_path();
        
        [filename, results_folder_name] = uiputfile({'*.yml','Yaml Files (*.yml)'},'Choose Parameters File Name', [DIRS.configDirectory, filesep, [DATA.DataFileName '_' DATA.mammal] ]);
        
        if ~isequal(results_folder_name, 0)
            DIRS.configDirectory = results_folder_name;
            full_file_name = fullfile(results_folder_name, filename);
            rhrv_save_defaults( full_file_name );
            
            temp_rhrv_default_values = ReadYaml(full_file_name);
            
            temp_hrv_freq = temp_rhrv_default_values.hrv_freq;
            temp_mse = temp_rhrv_default_values.mse;
            
            temp_rhrv_default_values = rmfield(temp_rhrv_default_values, {'hrv_freq'; 'rqrs'; 'rhrv'});
            
            temp_hrv_freq = rmfield(temp_hrv_freq, {'methods'; 'power_methods'; 'extra_bands'});
            temp_mse = rmfield(temp_mse, {'mse_metrics'});
            
            temp_rhrv_default_values.hrv_freq = temp_hrv_freq;
            temp_rhrv_default_values.mse = temp_mse;
            
            result = WriteYaml(full_file_name, temp_rhrv_default_values);
        end
    end
%%
    function PSD_pushbutton_Callback( src, ~ )
        if get(src, 'Value')
            set(src, 'String', 'Log');
            DATA.freq_yscale = 'linear';
        else
            set(src, 'String', 'Linear');
            DATA.freq_yscale = 'log';
        end
        if ~isempty(DATA.pd_freq)
            plot_hrv_freq_spectrum(GUI.FrequencyAxes1, DATA.pd_freq, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
        end
    end
%%
    function batch_Edit_Callback( src, ~ )
        
        src_tag = get(src, 'Tag');
        
        if strcmp(src_tag, 'overlap')
            param_value = str2double(get(src, 'String'));
            if param_value >= 0 && param_value < 100
                isInputNumeric = 1;
            else
                old_param_val = DATA.BatchParams.(src_tag);
                set(src, 'String', num2str(old_param_val));
                %isInputNumeric = 0;
                warndlg('Please, check your input');
                return;
            end
        else
            gui_value = get(src, 'String');
            [param_value, isInputNumeric]  = calcDurationInSeconds(src, gui_value, DATA.BatchParams.(src_tag));
        end
        
        if isInputNumeric
            
            if strcmp(src_tag, 'startTime')
                if param_value > DATA.Filt_MaxSignalLength - DATA.BatchParams.windowLength + 1
                    set(src, 'String', calcDuration(DATA.BatchParams.(src_tag), 0));
                    errordlg('Selected window start time must be less then signal length!', 'Input Error');
                    return;
                else
                    set(GUI.Filt_RawDataSlider, 'Value', param_value);
                    %DATA.Filt_FirstSecond2Show = param_value;
                    set( GUI.Filt_FirstSecond, 'String', calcDuration(param_value, 0));
                end
            elseif strcmp(src_tag, 'endTime')
                if param_value < 0 || param_value > DATA.Filt_MaxSignalLength
                    set(src, 'String', calcDuration(DATA.BatchParams.(src_tag), 0));
                    errordlg('Selected window end time must be grater than 0 and less then signal length!', 'Input Error');
                    return;
                end
            elseif strcmp(src_tag, 'windowLength')
                if  param_value > DATA.Filt_MaxSignalLength
                    set(src, 'String', calcDuration(DATA.BatchParams.(src_tag), 0));
                    errordlg('Selected window size must be less then signal length!', 'Input Error');
                    return;
                elseif param_value <= 10
                    set(src, 'String', calcDuration(DATA.BatchParams.(src_tag), 0));
                    errordlg('Selected window size must be greater then 10 sec!', 'Input Error');
                    return;
                else
                    %DATA.Filt_MyWindowSize = param_value;
                    setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, param_value, [(double(param_value)/10)/double(DATA.Filt_MaxSignalLength) , double(param_value)/double(DATA.Filt_MaxSignalLength) ]);
                    set( GUI.Filt_WindowSize, 'String', calcDuration(param_value, 0));
                end
            end
            
            DATA.BatchParams.(src_tag) = param_value;
            clear_statistics_plots();
            clearStatTables();
            calcBatchWinNum();
            plotFilteredData();
            plotMultipleWindows();            
            %setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
        end
    end
%%
    function calcBatchWinNum()
       
        batch_window_start_time = DATA.BatchParams.startTime;
        %batch_window_end_time = DATA.BatchParams.endTime;
        batch_window_length = DATA.BatchParams.windowLength;
        batch_overlap = DATA.BatchParams.overlap/100;
        
        %DATA.BatchParams.winNum = floor(round((DATA.BatchParams.endTime - DATA.BatchParams.startTime)) / (DATA.BatchParams.windowLength * (1 - DATA.BatchParams.overlap/100)));
        
        DATA.BatchParams.winNum = floor(round(((DATA.BatchParams.endTime - DATA.BatchParams.startTime)/DATA.BatchParams.windowLength) - 1) * (1/(1-DATA.BatchParams.overlap/100)) + 1);
        DATA.BatchParams.effectiveEndTime = batch_window_start_time+batch_window_length + (DATA.BatchParams.winNum - 1) * (1 - batch_overlap) * batch_window_length;
        
%         i = 0;
%         while batch_window_start_time + batch_window_length <= batch_window_end_time
%             batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
%             i = i + 1;
%         end        
%         DATA.BatchParams.winNum = i;
        
        set(GUI.batch_winNum, 'String', num2str(DATA.BatchParams.winNum));        
        if DATA.BatchParams.winNum <= 0
            errordlg('Please, check your input! Windows number must be greater than 0!', 'Input Error');
        elseif DATA.BatchParams.winNum == 1            
            %setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.BatchParams.windowLength, [(double(DATA.BatchParams.windowLength)/10)/double(DATA.Filt_MaxSignalLength) , double(DATA.BatchParams.windowLength)/double(DATA.Filt_MaxSignalLength) ]);
            GUI.Filt_RawDataSlider.Enable = 'on';
        else
            GUI.Filt_RawDataSlider.Enable = 'off';
        end
    end
%%
    function plotMultipleWindows()
        
        batch_win_num = DATA.BatchParams.winNum;
        
        if batch_win_num > 0
            %if batch_win_num ~= 1
            %                 clear_statistics_plots();
            %                 clearStatTables();
            %end
            
            if isfield(GUI, 'first_rect_handle')
                delete(GUI.first_rect_handle);
            end
            
            if isfield(GUI, 'rect_handle')
                for i = 1 : length(GUI.rect_handle)
                    delete(GUI.rect_handle(i));
                end
            end
            
            batch_window_start_time = DATA.BatchParams.startTime;
            %batch_window_end_time = DATA.BatchParams.endTime;
            batch_window_length = DATA.BatchParams.windowLength;
            batch_overlap = DATA.BatchParams.overlap/100;
            
            GUI.rect_handle = gobjects(batch_win_num, 1);            
            
            for i = 1 : batch_win_num
                
                
%                 batch_window_start_time
%                 batch_window_start_time + batch_window_length
%                 i
                
%                 if batch_window_start_time + batch_window_length > batch_window_end_time %DATA.tnn(end)
%                     break;
%                 end
                
                filt_win_indexes = find(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                
                GUI.rect_handle(i) = fill([DATA.tnn(filt_win_indexes(1)) DATA.tnn(filt_win_indexes(1)) DATA.tnn(filt_win_indexes(end)) DATA.tnn(filt_win_indexes(end))], ...
                    [DATA.MinYLimit DATA.MaxYLimit DATA.MaxYLimit DATA.MinYLimit], DATA.rectangle_color ,'FaceAlpha', 0.15, 'Parent', GUI.RawDataAxes);
                %uistack(GUI.rect_handle(i), 'bottom');
                
                if i == DATA.active_window
                    set(GUI.rect_handle(i), 'LineWidth', 2, 'FaceAlpha', 0.15);
                    uistack(GUI.rect_handle(i), 'top');
                    %set(GUI.rect_handle(i), 'LineStyle','none', 'FaceAlpha', 0);
                end
                
                
                batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
            end
        end
    end
%%
    function clearStatData()
        timeData = [];
        timeRowsNames = [];
        timeDescriptions = [];
        time_data = [];
        
        fragData = [];
        fragRowsNames = [];
        fragDescriptions = [];
        frag_data = [];
        
        fd_lombData = [];
        fd_LombRowsNames = [];
        fd_lombDescriptions = [];
        fd_lomb_data = [];
        
        fd_arData = [];
        fd_ArRowsNames = [];
        
        fd_welchData = [];
        fd_WelchRowsNames = [];
        
        nonlinData = [];
        nonlinRowsNames = [];
        nonlinDescriptions = [];
        nonlin_data = [];
    end
%%
    function calcTimeStatistics(waitbar_handle)
        
        batch_window_start_time = DATA.BatchParams.startTime;
        batch_window_end_time = DATA.BatchParams.endTime;
        batch_window_length = DATA.BatchParams.windowLength;
        batch_overlap = DATA.BatchParams.overlap/100;
        batch_win_num = DATA.BatchParams.winNum;
        
        for i = 1 : batch_win_num
            
%             if batch_window_start_time + batch_window_length > batch_window_end_time %DATA.tnn(end)
%                 break;
%             end
%             batch_window_start_time
                        
            t0 = cputime;
            
            filt_win_indexes = find(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
            nni_window = DATA.nni(filt_win_indexes(1) : filt_win_indexes(end));
            
            try
                waitbar(1 / 3, waitbar_handle, ['Calculating time measures for window ' num2str(i)]);
                % Time Domain metrics
                fprintf('[win % d: %.3f] >> rhrv: Calculating time-domain metrics...\n', i, cputime-t0);
                [hrv_td, pd_time] = hrv_time(nni_window);
                % Heart rate fragmentation metrics
                fprintf('[win % d: %.3f] >> rhrv: Calculating fragmentation metrics...\n', i, cputime-t0);
                hrv_frag = hrv_fragmentation(nni_window);
                
                [timeData, timeRowsNames, timeDescriptions] = table2cell_StatisticsParam(hrv_td);
                [fragData, fragRowsNames, fragDescriptions] = table2cell_StatisticsParam(hrv_frag);
                
                if i == DATA.active_window
                    
                    GUI.TimeParametersTableRowName = timeRowsNames;
                    GUI.TimeParametersTableData = [timeDescriptions timeData];
                    GUI.TimeParametersTable.Data = [timeRowsNames timeData];
                    
                    GUI.FragParametersTableRowName = fragRowsNames;
                    GUI.FragParametersTableData = [fragDescriptions fragData];
                    GUI.FragParametersTable.Data = [fragRowsNames fragData];
                    
                    updateTimeStatistics();
                    
                    DATA.pd_time = pd_time;
                    plot_time_statistics_results();
                end
            catch e
                DATA.timeStatPartRowNumber = 0;
                close(waitbar_handle);
                errordlg(['hrv_nonlinear: ' e.message], 'Input Error');
                rethrow(e);
                %return;
            end
            
            if i == 1
                DATA.TimeStat.RowsNames = [timeRowsNames; fragRowsNames];
                DATA.TimeStat.Data = [[timeDescriptions; fragDescriptions] [timeData; fragData]];
            else
                DATA.TimeStat.Data = [DATA.TimeStat.Data [timeData; fragData]];
            end
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        updateMainStatisticsTable(0, DATA.TimeStat.RowsNames, DATA.TimeStat.Data);
        [rn, ~] = size(DATA.TimeStat.RowsNames);
        %DATA.timeStatPartRowNumber = DATA.TimeStat.RowsNamesength(GUI.StatisticsTable.RowName);
        DATA.timeStatPartRowNumber = rn;
    end
%%
    function calcFrequencyStatistics(waitbar_handle)
        
        batch_window_start_time = DATA.BatchParams.startTime;
%         batch_window_end_time = DATA.BatchParams.endTime;
        batch_window_length = DATA.BatchParams.windowLength;
        batch_overlap = DATA.BatchParams.overlap/100;
        batch_win_num = DATA.BatchParams.winNum;
        
        for i = 1 : batch_win_num
            
%             if batch_window_start_time + batch_window_length > batch_window_end_time %DATA.tnn(end)
%                 break;
%             end
            
            t0 = cputime;
            
            filt_win_indexes = find(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
            nni_window = DATA.nni(filt_win_indexes(1) : filt_win_indexes(end));
            
            try
                waitbar(2 / 3, waitbar_handle, ['Calculating frequency measures for window ' num2str(i)]);
                % Freq domain metrics
                fprintf('[win % d: %.3f] >> rhrv: Calculating frequency-domain metrics...\n', i, cputime-t0);
                [ hrv_fd, ~, ~, pd_freq ] = hrv_freq(nni_window, 'methods', {'lomb','welch','ar'},...
                    'power_methods', {'lomb','welch','ar'});
                
                hrv_fd_lomb = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_lomb')), hrv_fd.Properties.VariableNames)));
                hrv_fd_ar = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_ar')), hrv_fd.Properties.VariableNames)));
                hrv_fd_welch = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, 'welch')), hrv_fd.Properties.VariableNames)));
                
                [fd_lombData, fd_LombRowsNames, fd_lombDescriptions] = table2cell_StatisticsParam(hrv_fd_lomb);
                [fd_arData, fd_ArRowsNames, fd_ArDescriptions] = table2cell_StatisticsParam(hrv_fd_ar);
                [fd_welchData, fd_WelchRowsNames, fd_WelchDescriptions] = table2cell_StatisticsParam(hrv_fd_welch);
                
                if i == DATA.active_window
                    
                    %                     GUI.FrequencyParametersTableLombRowName = fd_LombRowsNames;
                    %                     GUI.FrequencyParametersTableRowName = strrep(fd_LombRowsNames,'_LOMB','');
                    
                    GUI.FrequencyParametersTableLombRowName = fd_WelchRowsNames;
                    GUI.FrequencyParametersTableRowName = strrep(fd_LombRowsNames,'_WELCH','');
                    
                    GUI.FrequencyParametersTable.Data = [GUI.FrequencyParametersTableRowName fd_lombData fd_welchData fd_arData];
                    
                    DATA.pd_freq = pd_freq;
                    plot_frequency_statistics_results();
                end
            catch e
                DATA.frequencyStatPartRowNumber = 0;
                close(waitbar_handle);
                errordlg(['hrv_nonlinear: ' e.message], 'Input Error');
                rethrow(e);
                %return;
            end
            
            if i == 1
                
                DATA.FrStat.LombWindowsData.RowsNames = fd_LombRowsNames;
                DATA.FrStat.ArWindowsData.RowsNames = fd_ArRowsNames;
                DATA.FrStat.WelchWindowsData.RowsNames = fd_WelchRowsNames;
                
                DATA.FrStat.LombWindowsData.Data = [fd_lombDescriptions fd_lombData];
                DATA.FrStat.ArWindowsData.Data = [fd_ArDescriptions fd_arData];
                DATA.FrStat.WelchWindowsData.Data = [fd_WelchDescriptions fd_welchData];
            else
                
                DATA.FrStat.LombWindowsData.Data = [DATA.FrStat.LombWindowsData.Data fd_lombData];
                DATA.FrStat.ArWindowsData.Data = [DATA.FrStat.ArWindowsData.Data fd_arData];
                DATA.FrStat.WelchWindowsData.Data = [DATA.FrStat.WelchWindowsData.Data fd_welchData];
            end
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        [StatRowsNames, StatData] = setFrequencyMethodData();
        updateMainStatisticsTable(DATA.timeStatPartRowNumber, StatRowsNames, StatData);
        [rn, ~] = size(StatRowsNames);
        DATA.frequencyStatPartRowNumber = rn; %length(GUI.StatisticsTable.RowName);
    end
%%
    function calcNonlinearStatistics(waitbar_handle)
        
        batch_window_start_time = DATA.BatchParams.startTime;
        batch_window_length = DATA.BatchParams.windowLength;
        batch_overlap = DATA.BatchParams.overlap/100;
        batch_win_num = DATA.BatchParams.winNum;
        
        for i = 1 : batch_win_num
            
%             if batch_window_start_time + batch_window_length > DATA.tnn(end)
%                 break;
%             end
            
            t0 = cputime;
            
            filt_win_indexes = find(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
            nni_window = DATA.nni(filt_win_indexes(1) : filt_win_indexes(end));
            
            try
                waitbar(3 / 3, waitbar_handle, ['Calculating nolinear measures for window ' num2str(i)]);
                fprintf('[win % d: %.3f] >> rhrv: Calculating nonlinear metrics...\n', i, cputime-t0);
                [hrv_nl, pd_nl] = hrv_nonlinear(nni_window);
                
                [nonlinData, nonlinRowsNames, nonlinDescriptions] = table2cell_StatisticsParam(hrv_nl);
                
                if i == DATA.active_window
                    GUI.NonLinearTableRowName = nonlinRowsNames;
                    GUI.NonLinearTableData = [nonlinDescriptions nonlinData];
                    GUI.NonLinearTable.Data = [nonlinRowsNames nonlinData];
                    
                    DATA.pd_nl = pd_nl;
                    plot_nonlinear_statistics_results();
                end
            catch e
                close(waitbar_handle);
                errordlg(['hrv_nonlinear: ' e.message], 'Input Error');
                rethrow(e);
                %return;
            end
            if i == 1
                DATA.NonLinStat.RowsNames = nonlinRowsNames;
                DATA.NonLinStat.Data = [nonlinDescriptions nonlinData];
            else
                DATA.NonLinStat.Data = [DATA.NonLinStat.Data nonlinData];
            end
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        updateMainStatisticsTable(DATA.timeStatPartRowNumber + DATA.frequencyStatPartRowNumber, DATA.NonLinStat.RowsNames, DATA.NonLinStat.Data);
    end

%%
    function calcStatistics()
        
        GUI.StatisticsTable.ColumnName = {'Description'};
        
        if DATA.BatchParams.winNum == 1
            GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, 'Values');
        else
            
            for i = 1 : DATA.BatchParams.winNum
                GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, ['W' num2str(i)]);
            end
        end
        
        waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
        
        calcTimeStatistics(waitbar_handle);
        calcFrequencyStatistics(waitbar_handle);
        calcNonlinearStatistics(waitbar_handle);
        
        close(waitbar_handle);
    end
%%
    function RunMultSegments_pushbutton_Callback( ~, ~ )
        
        clear_statistics_plots();
        clearStatTables();
        clearStatData();
        
        set(GUI.Filt_WindowSize, 'Enable', 'inactive');
        set(GUI.Filt_FirstSecond, 'Enable', 'inactive');
        
        calcStatistics();
    end
%%
    function onHelp( ~, ~ )
    end

%%
    function onExit( ~, ~ )
        % User wants to quit out of the application
        if isfield(GUI, 'SaveFiguresWindow') && isvalid(GUI.SaveFiguresWindow)
            delete( GUI.SaveFiguresWindow );
        end
        delete( GUI.Window );
    end % onExit

%     function redrawDemo()
%         testData = magic(5);
%         plot(GUI.TimeAxes1, testData);
%
%         %         hAxes = findobj('Type', 'Axes', 'Tag', 'MyTag');
%         %         parent2Delete = hAxes.Parent;
%         %         hAxes.Parent = GUI.TimeAxes1;
%         %         delete(parent2Delete);
%
%     end
end % EOF
