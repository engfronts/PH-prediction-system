function Academic_Ensemble_Prediction_System_v3

    fig = uifigure('Name', 'Academic Ensemble Prediction System v3.0', ...
                   'Position', [30, 30, 1700, 950], ...
                   'Color', [0.96, 0.96, 0.98]);
    
    colors = struct();
    colors.nature = [
        0.8353, 0.2431, 0.3098;
        0.9725, 0.6706, 0.3804;
        0.4784, 0.6784, 0.8039;
        0.2000, 0.2627, 0.5490;
        0.8980, 0.5882, 0.5765;
        0.9882, 0.8431, 0.6863;
        0.7373, 0.8353, 0.9059;
        0.6000, 0.6000, 0.7843;
        0.1333, 0.5451, 0.1333;
        0.8039, 0.5216, 0.2471;
        0.2549, 0.4118, 0.8824;
        0.7059, 0.3451, 0.0235;
        0.0000, 0.5020, 0.5020;
        0.5020, 0.0000, 0.5020;
        0.8471, 0.7490, 0.8471;
        0.1961, 0.8039, 0.1961;
    ];
    
    colors.svr = colors.nature(1,:);
    colors.gpr = colors.nature(3,:);
    colors.rf = colors.nature(2,:);
    colors.ensemble = colors.nature(4,:);
    colors.forest = colors.nature(9,:);
    
    colors.panel_bg = [0.97, 0.98, 1.0];
    colors.title_fg = [0.15, 0.25, 0.45];
    colors.text_fg = [0.25, 0.25, 0.35];
    colors.success = [0.1333, 0.5451, 0.1333];
    colors.warning = [0.9725, 0.6706, 0.3804];
    colors.error = [0.8353, 0.2431, 0.3098];
    
    app_data = struct();
    app_data.model_loaded = false;
    app_data.history = {};
    app_data.test_data = [];
    app_data.colors = colors;
    app_data.feature_names = {};
    
    main_grid = uigridlayout(fig, [1, 2]);
    main_grid.ColumnWidth = {'1.1x', '3x'};
    main_grid.Padding = [12 12 12 12];
    main_grid.ColumnSpacing = 15;
    
    left_panel = uipanel(main_grid, ...
        'Title', '  MODEL CONFIGURATION & INPUT  ', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'FontName', 'Arial', ...
        'BackgroundColor', colors.panel_bg, ...
        'ForegroundColor', colors.title_fg, ...
        'BorderType', 'line');
    left_panel.Layout.Row = 1;
    left_panel.Layout.Column = 1;
    
    left_grid = uigridlayout(left_panel, [32, 1]);
    left_grid.RowHeight = repmat({'fit'}, 1, 32);
    left_grid.Padding = [10 8 10 8];
    left_grid.RowSpacing = 4;
    
    createSectionLabel(left_grid, 'MODEL MANAGEMENT', colors);
    
    load_btn = uibutton(left_grid, 'push', ...
        'Text', '📂 LOAD MODEL', ...
        'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'BackgroundColor', colors.nature(4,:), ...
        'FontColor', [1, 1, 1], ...
        'ButtonPushedFcn', @(~,~) loadModel());
    
    model_status = uilabel(left_grid, ...
        'Text', '● Status: Awaiting Model', ...
        'FontSize', 10, 'FontName', 'Arial', ...
        'FontColor', colors.error, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
    
    info_panel = uipanel(left_grid, ...
        'BackgroundColor', [0.95, 0.96, 0.98], ...
        'BorderType', 'line');
    info_grid = uigridlayout(info_panel, [5, 1]);
    info_grid.RowHeight = repmat({'fit'}, 1, 5);
    info_grid.Padding = [8 4 8 4];
    info_grid.RowSpacing = 2;
    
    info_features = uilabel(info_grid, 'Text', 'Features: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    info_svr_weight = uilabel(info_grid, 'Text', 'SVR Weight: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.svr);
    info_gpr_weight = uilabel(info_grid, 'Text', 'GPR Weight: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.gpr);
    info_rf_weight = uilabel(info_grid, 'Text', 'RF Weight: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.rf);
    info_samples = uilabel(info_grid, 'Text', 'Test Samples: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    
    createSectionLabel(left_grid, 'FEATURE INPUT VECTOR', colors);
    
    n_features = 11;
    feature_inputs = cell(n_features, 1);
    
    for i = 1:n_features
        feature_grid = uigridlayout(left_grid, [1, 2]);
        feature_grid.ColumnWidth = {'0.4x', '1x'};
        feature_grid.Padding = [0 1 0 1];
        
        if mod(i, 2) == 1
            label_color = colors.nature(4,:);
        else
            label_color = colors.nature(3,:) * 0.8;
        end
        
        uilabel(feature_grid, 'Text', sprintf('F%d:', i), ...
            'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
            'HorizontalAlignment', 'right', ...
            'FontColor', label_color);
        
        feature_inputs{i} = uieditfield(feature_grid, 'numeric', ...
            'Value', 0, 'FontSize', 10, 'FontName', 'Arial', ...
            'ValueDisplayFormat', '%.4f', ...
            'BackgroundColor', [1, 1, 1]);
    end
    
    createSectionLabel(left_grid, 'BENCHMARK SAMPLES', colors);
    
    sample_grid = uigridlayout(left_grid, [2, 2]);
    sample_grid.ColumnWidth = {'1x', '1x'};
    sample_grid.RowHeight = {'fit', 'fit'};
    sample_grid.Padding = [0 0 0 0];
    sample_grid.ColumnSpacing = 6;
    sample_grid.RowSpacing = 4;
    
    sample_colors = {colors.nature(9,:), colors.nature(2,:), ...
                     colors.nature(14,:), colors.nature(3,:)};
    sample_btns = cell(4, 1);
    sample_names = {'Mean', 'High', 'Low', 'Random'};
    
    for i = 1:4
        sample_btns{i} = uibutton(sample_grid, 'push', ...
            'Text', sample_names{i}, ...
            'FontSize', 10, 'FontName', 'Arial', ...
            'BackgroundColor', sample_colors{i}, ...
            'FontColor', [1, 1, 1], ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @(~,~) loadSample(i));
    end
    
    createSectionLabel(left_grid, 'OPERATIONS', colors);
    
    predict_btn = uibutton(left_grid, 'push', ...
        'Text', '▶ RUN PREDICTION', ...
        'FontSize', 13, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'BackgroundColor', colors.nature(1,:), ...
        'FontColor', [1, 1, 1], ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) executePrediction());
    
    op_grid = uigridlayout(left_grid, [1, 3]);
    op_grid.ColumnWidth = {'1x', '1x', '1x'};
    op_grid.Padding = [0 0 0 0];
    op_grid.ColumnSpacing = 6;
    
    clear_btn = uibutton(op_grid, 'push', ...
        'Text', 'Clear', 'FontSize', 10, 'FontName', 'Arial', ...
        'BackgroundColor', colors.nature(8,:), ...
        'FontColor', [1, 1, 1], ...
        'ButtonPushedFcn', @(~,~) clearInputs());
    
    batch_btn = uibutton(op_grid, 'push', ...
        'Text', 'Batch', 'FontSize', 10, 'FontName', 'Arial', ...
        'BackgroundColor', colors.nature(13,:), ...
        'FontColor', [1, 1, 1], ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) batchPrediction());
    
    export_btn = uibutton(op_grid, 'push', ...
        'Text', 'Export', 'FontSize', 10, 'FontName', 'Arial', ...
        'BackgroundColor', colors.nature(11,:), ...
        'FontColor', [1, 1, 1], ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) exportResults());
    
    createSectionLabel(left_grid, 'SESSION STATISTICS', colors);
    
    stats_info_panel = uipanel(left_grid, ...
        'BackgroundColor', [0.95, 0.96, 0.98], ...
        'BorderType', 'line');
    stats_info_grid = uigridlayout(stats_info_panel, [4, 1]);
    stats_info_grid.RowHeight = repmat({'fit'}, 1, 4);
    stats_info_grid.Padding = [8 4 8 4];
    stats_info_grid.RowSpacing = 2;
    
    quick_predictions = uilabel(stats_info_grid, ...
        'Text', 'Total Predictions: 0', ...
        'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'FontColor', colors.ensemble);
    quick_avg = uilabel(stats_info_grid, 'Text', 'Session Avg: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    quick_range = uilabel(stats_info_grid, 'Text', 'Range: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    quick_time = uilabel(stats_info_grid, 'Text', 'Last Update: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    
    createSectionLabel(left_grid, 'MODEL CONFIDENCE', colors);
    
    conf_panel = uipanel(left_grid, ...
        'BackgroundColor', [0.95, 0.96, 0.98], ...
        'BorderType', 'line');
    conf_grid = uigridlayout(conf_panel, [3, 1]);
    conf_grid.RowHeight = repmat({'fit'}, 1, 3);
    conf_grid.Padding = [8 4 8 4];
    conf_grid.RowSpacing = 2;
    
    conf_agreement = uilabel(conf_grid, 'Text', 'Model Agreement: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    conf_variance = uilabel(conf_grid, 'Text', 'Inter-model Std: --', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    conf_level = uilabel(conf_grid, 'Text', '● Confidence: --', ...
        'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'FontColor', colors.text_fg);
    
    createSectionLabel(left_grid, 'SYSTEM', colors);
    
    sys_panel = uipanel(left_grid, ...
        'BackgroundColor', [0.95, 0.96, 0.98], ...
        'BorderType', 'line');
    sys_grid = uigridlayout(sys_panel, [2, 1]);
    sys_grid.RowHeight = repmat({'fit'}, 1, 2);
    sys_grid.Padding = [8 4 8 4];
    sys_grid.RowSpacing = 2;
    
    sys_version = uilabel(sys_grid, 'Text', 'Version: 3.0 (Style: v5.8)', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.text_fg);
    sys_status = uilabel(sys_grid, 'Text', '● System Ready', ...
        'FontSize', 9, 'FontName', 'Arial', 'FontColor', colors.success);
    
    right_panel = uipanel(main_grid, ...
        'Title', '  PREDICTION RESULTS & ANALYSIS  ', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'FontName', 'Arial', ...
        'BackgroundColor', colors.panel_bg, ...
        'ForegroundColor', colors.title_fg, ...
        'BorderType', 'line');
    right_panel.Layout.Row = 1;
    right_panel.Layout.Column = 2;
    
    right_grid = uigridlayout(right_panel, [4, 1]);
    right_grid.RowHeight = {'fit', 'fit', '2.8x', '1x'};
    right_grid.Padding = [12 12 12 12];
    right_grid.RowSpacing = 10;
    
    result_panel = uipanel(right_grid, ...
        'Title', ' Model Predictions ', ...
        'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'BackgroundColor', [0.98, 0.98, 1.0], ...
        'ForegroundColor', colors.title_fg);
    result_panel.Layout.Row = 1;
    
    result_grid = uigridlayout(result_panel, [2, 4]);
    result_grid.RowHeight = {'fit', 'fit'};
    result_grid.ColumnWidth = {'1x', '1x', '1x', '1x'};
    result_grid.Padding = [15 8 15 8];
    result_grid.RowSpacing = 6;
    result_grid.ColumnSpacing = 15;
    
    model_info = {'SVR', colors.svr; 'GPR', colors.gpr; ...
                  'RF', colors.rf; 'ENSEMBLE', colors.ensemble};
    
    result_labels = cell(4, 1);
    for i = 1:4
        uilabel(result_grid, 'Text', [model_info{i,1} ':'], ...
            'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Arial', ...
            'HorizontalAlignment', 'right', ...
            'FontColor', model_info{i,2});
        result_labels{i} = uilabel(result_grid, 'Text', '---', ...
            'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Arial', ...
            'FontColor', model_info{i,2});
    end
    
    stats_panel = uipanel(right_grid, ...
        'Title', ' Statistical Metrics ', ...
        'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'BackgroundColor', [0.98, 0.98, 1.0], ...
        'ForegroundColor', colors.title_fg);
    stats_panel.Layout.Row = 2;
    
    stats_grid = uigridlayout(stats_panel, [1, 5]);
    stats_grid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
    stats_grid.Padding = [15 6 15 6];
    stats_grid.ColumnSpacing = 10;
    
    stats_labels = cell(5, 1);
    stats_names = {'Mean', 'Std Dev', 'Min', 'Max', 'CV (%)'};
    stats_colors = {colors.nature(4,:), colors.nature(3,:), ...
                    colors.nature(9,:), colors.nature(1,:), colors.nature(2,:)};
    
    for i = 1:5
        stat_box = uigridlayout(stats_grid, [2, 1]);
        stat_box.RowHeight = {'fit', 'fit'};
        stat_box.Padding = [4 4 4 4];
        
        uilabel(stat_box, 'Text', stats_names{i}, ...
            'FontSize', 9, 'FontWeight', 'bold', 'FontName', 'Arial', ...
            'HorizontalAlignment', 'center', ...
            'FontColor', colors.text_fg);
        
        stats_labels{i} = uilabel(stat_box, 'Text', '--', ...
            'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial', ...
            'HorizontalAlignment', 'center', ...
            'FontColor', stats_colors{i});
    end
    
    chart_panel = uipanel(right_grid, ...
        'Title', ' Visualization & Analysis (2×3) ', ...
        'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'BackgroundColor', [1, 1, 1], ...
        'ForegroundColor', colors.title_fg);
    chart_panel.Layout.Row = 3;
    
    chart_grid = uigridlayout(chart_panel, [2, 3]);
    chart_grid.Padding = [8 8 8 8];
    chart_grid.RowSpacing = 10;
    chart_grid.ColumnSpacing = 10;
    
    ax = cell(6, 1);
    ax_titles = {'(a) Input Feature Vector', '(b) Prediction Distribution', ...
                 '(c) Model Comparison', '(d) Feature Deviation', ...
                 '(e) Residual Analysis', '(f) Prediction History'};
    
    for i = 1:6
        row = ceil(i/3);
        col = mod(i-1, 3) + 1;
        
        ax{i} = uiaxes(chart_grid);
        ax{i}.Layout.Row = row;
        ax{i}.Layout.Column = col;
        
        ax{i}.Title.String = ax_titles{i};
        ax{i}.Title.FontSize = 10;
        ax{i}.Title.FontWeight = 'bold';
        ax{i}.FontSize = 9;
        ax{i}.FontName = 'Arial';
        ax{i}.Box = 'on';
        ax{i}.LineWidth = 0.8;
        ax{i}.TickDir = 'out';
        ax{i}.GridAlpha = 0.15;
        ax{i}.MinorGridAlpha = 0.05;
    end
    
    history_panel = uipanel(right_grid, ...
        'Title', ' Prediction History Log ', ...
        'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
        'BackgroundColor', [0.98, 0.98, 1.0], ...
        'ForegroundColor', colors.title_fg);
    history_panel.Layout.Row = 4;
    
    history_grid = uigridlayout(history_panel, [1, 1]);
    history_grid.Padding = [5 5 5 5];
    
    history_table = uitable(history_grid, ...
        'ColumnName', {'Time', 'SVR', 'GPR', 'RF', 'Ensemble', 'Std', 'Conf'}, ...
        'ColumnWidth', {70, 85, 85, 85, 85, 70, 60}, ...
        'Data', {}, ...
        'FontSize', 9, ...
        'FontName', 'Arial');
    
    function createSectionLabel(parent, text, colors)
        uilabel(parent, 'Text', text, ...
            'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial', ...
            'HorizontalAlignment', 'center', ...
            'FontColor', colors.title_fg);
    end
    
    function loadModel()
        try
            if exist('enhanced_ensemble_results.mat', 'file')
                model_file = 'enhanced_ensemble_results.mat';
                fprintf('Auto-loading: %s\n', model_file);
            else
                [file, path] = uigetfile('*.mat', 'Select Model File');
                if isequal(file, 0), return; end
                model_file = fullfile(path, file);
            end
            
            loaded = load(model_file);
            
            required = {'svr_model', 'gpr_model', 'rf_model', ...
                       'mean_X', 'std_X', 'mean_Y', 'std_Y', 'weights'};
            for i = 1:length(required)
                if ~isfield(loaded, required{i})
                    uialert(fig, sprintf('Missing: %s', required{i}), 'Error');
                    return;
                end
            end
            
            app_data.svr_model = loaded.svr_model;
            app_data.gpr_model = loaded.gpr_model;
            app_data.rf_model = loaded.rf_model;
            app_data.mean_X = loaded.mean_X;
            app_data.std_X = loaded.std_X;
            app_data.mean_Y = loaded.mean_Y;
            app_data.std_Y = loaded.std_Y;
            app_data.weights = loaded.weights;
            app_data.model_loaded = true;
            
            if isfield(loaded, 'Y_test_weighted')
                app_data.test_data = loaded.Y_test_weighted;
            end
            if isfield(loaded, 'feature_names')
                app_data.feature_names = loaded.feature_names;
            end
            
            model_status.Text = '● Status: Model Loaded';
            model_status.FontColor = colors.success;
            
            info_features.Text = sprintf('Features: %d', length(app_data.mean_X));
            info_svr_weight.Text = sprintf('SVR Weight: %.4f', app_data.weights(1));
            info_gpr_weight.Text = sprintf('GPR Weight: %.4f', app_data.weights(2));
            info_rf_weight.Text = sprintf('RF Weight: %.4f', app_data.weights(3));
            info_samples.Text = sprintf('Test Samples: %d', length(app_data.test_data));
            
            predict_btn.Enable = 'on';
            batch_btn.Enable = 'on';
            export_btn.Enable = 'on';
            for i = 1:4
                sample_btns{i}.Enable = 'on';
            end
            
            sys_status.Text = '● Model Active';
            sys_status.FontColor = colors.success;
            
            uialert(fig, 'Model loaded successfully!', 'Success', 'Icon', 'success');
            
        catch ME
            uialert(fig, sprintf('Load failed: %s', ME.message), 'Error');
        end
    end
    
    function loadSample(sample_num)
        if ~app_data.model_loaded, return; end
        
        switch sample_num
            case 1
                vals = app_data.mean_X;
            case 2
                vals = app_data.mean_X + app_data.std_X;
            case 3
                vals = app_data.mean_X - 0.5 * app_data.std_X;
            case 4
                vals = app_data.mean_X + randn(size(app_data.mean_X)) .* app_data.std_X * 0.5;
        end
        
        for i = 1:min(length(feature_inputs), length(vals))
            feature_inputs{i}.Value = vals(i);
        end
    end
    
    function clearInputs()
        for i = 1:length(feature_inputs)
            feature_inputs{i}.Value = 0;
        end
        for i = 1:4
            result_labels{i}.Text = '---';
        end
        for i = 1:5
            stats_labels{i}.Text = '--';
        end
        for i = 1:6
            cla(ax{i});
        end
    end
    
    function executePrediction()
        if ~app_data.model_loaded
            uialert(fig, 'Please load model first!', 'Warning');
            return;
        end
        
        try
            X_input = zeros(1, length(feature_inputs));
            for i = 1:length(feature_inputs)
                X_input(i) = feature_inputs{i}.Value;
            end
            
            X_norm = (X_input - app_data.mean_X) ./ app_data.std_X;
            
            Y_svr_norm = predict(app_data.svr_model, X_norm);
            Y_svr = Y_svr_norm * app_data.std_Y + app_data.mean_Y;
            
            Y_gpr_norm = predict(app_data.gpr_model, X_norm);
            Y_gpr = Y_gpr_norm * app_data.std_Y + app_data.mean_Y;
            
            Y_rf = predict(app_data.rf_model, X_norm);
            if iscell(Y_rf), Y_rf = str2double(Y_rf{1}); end
            
            Y_ensemble = app_data.weights(1) * Y_svr + ...
                        app_data.weights(2) * Y_gpr + ...
                        app_data.weights(3) * Y_rf;
            
            result_labels{1}.Text = sprintf('%.4f', Y_svr);
            result_labels{2}.Text = sprintf('%.4f', Y_gpr);
            result_labels{3}.Text = sprintf('%.4f', Y_rf);
            result_labels{4}.Text = sprintf('%.4f', Y_ensemble);
            
            preds = [Y_svr, Y_gpr, Y_rf];
            pred_mean = mean(preds);
            pred_std = std(preds);
            pred_cv = abs(pred_std / pred_mean) * 100;
            
            stats_labels{1}.Text = sprintf('%.4f', pred_mean);
            stats_labels{2}.Text = sprintf('%.4f', pred_std);
            stats_labels{3}.Text = sprintf('%.4f', min(preds));
            stats_labels{4}.Text = sprintf('%.4f', max(preds));
            stats_labels{5}.Text = sprintf('%.2f', pred_cv);
            
            agreement = max(0, 100 * (1 - pred_std / abs(pred_mean)));
            conf_agreement.Text = sprintf('Model Agreement: %.1f%%', agreement);
            conf_variance.Text = sprintf('Inter-model Std: %.4f', pred_std);
            
            if agreement > 95
                conf_level.Text = '● Confidence: HIGH';
                conf_level.FontColor = colors.success;
                conf_str = 'HIGH';
            elseif agreement > 85
                conf_level.Text = '● Confidence: MEDIUM';
                conf_level.FontColor = colors.warning;
                conf_str = 'MED';
            else
                conf_level.Text = '● Confidence: LOW';
                conf_level.FontColor = colors.error;
                conf_str = 'LOW';
            end
            
            timestamp = datetime('now', 'Format', 'HH:mm:ss');
            new_record = {char(timestamp), sprintf('%.4f', Y_svr), ...
                         sprintf('%.4f', Y_gpr), sprintf('%.4f', Y_rf), ...
                         sprintf('%.4f', Y_ensemble), sprintf('%.4f', pred_std), conf_str};
            
            current_data = history_table.Data;
            if size(current_data, 1) >= 12
                current_data = current_data(1:11, :);
            end
            history_table.Data = [new_record; current_data];
            
            app_data.history = [app_data.history; ...
                {timestamp, Y_svr, Y_gpr, Y_rf, Y_ensemble, pred_std}];
            
            quick_predictions.Text = sprintf('Total Predictions: %d', size(app_data.history, 1));
            if size(app_data.history, 1) > 0
                all_ens = cellfun(@(x) x, app_data.history(:, 5));
                quick_avg.Text = sprintf('Session Avg: %.4f', mean(all_ens));
                quick_range.Text = sprintf('Range: [%.3f, %.3f]', min(all_ens), max(all_ens));
            end
            quick_time.Text = sprintf('Last: %s', char(timestamp));
            
            updateCharts(X_input, Y_svr, Y_gpr, Y_rf, Y_ensemble);
            
        catch ME
            uialert(fig, sprintf('Prediction failed: %s', ME.message), 'Error');
        end
    end
    
    function updateCharts(X_input, Y_svr, Y_gpr, Y_rf, Y_ensemble)
        c = colors;
        
        cla(ax{1});
        hold(ax{1}, 'on');
        
        bar_colors = zeros(length(X_input), 3);
        for i = 1:length(X_input)
            bar_colors(i,:) = c.nature(mod(i-1, size(c.nature,1))+1, :);
        end
        
        for i = 1:length(X_input)
            bar(ax{1}, i, X_input(i), 'FaceColor', bar_colors(i,:), ...
                'EdgeColor', bar_colors(i,:)*0.7, 'LineWidth', 1);
        end
        plot(ax{1}, 1:length(X_input), app_data.mean_X, '--', ...
             'Color', [0.3, 0.3, 0.3], 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 4);
        hold(ax{1}, 'off');
        ax{1}.XLabel.String = 'Feature Index';
        ax{1}.XLabel.FontWeight = 'bold';
        ax{1}.YLabel.String = 'Value';
        ax{1}.YLabel.FontWeight = 'bold';
        legend(ax{1}, {'Input', 'Mean'}, 'Location', 'best', 'Box', 'off', 'FontSize', 8);
        grid(ax{1}, 'on');
        
        cla(ax{2});
        if ~isempty(app_data.test_data)
            histogram(ax{2}, app_data.test_data, 35, ...
                'FaceColor', c.nature(7,:), 'EdgeColor', 'none', ...
                'FaceAlpha', 0.7, 'Normalization', 'probability');
            hold(ax{2}, 'on');
            yl = ylim(ax{2});
            plot(ax{2}, [Y_ensemble, Y_ensemble], yl, '-', ...
                 'Color', c.ensemble, 'LineWidth', 3);
            hold(ax{2}, 'off');
            ax{2}.XLabel.String = 'pH Value';
            ax{2}.XLabel.FontWeight = 'bold';
            ax{2}.YLabel.String = 'Probability';
            ax{2}.YLabel.FontWeight = 'bold';
            legend(ax{2}, {'Test Dist.', 'Current'}, 'Location', 'best', 'Box', 'off', 'FontSize', 8);
        end
        grid(ax{2}, 'on');
        
        cla(ax{3});
        predictions = [Y_svr, Y_gpr, Y_rf, Y_ensemble];
        model_colors = [c.svr; c.gpr; c.rf; c.ensemble];
        
        hold(ax{3}, 'on');
        for i = 1:4
            bar(ax{3}, i, predictions(i), 'FaceColor', model_colors(i,:), ...
                'EdgeColor', model_colors(i,:)*0.7, 'LineWidth', 1.5);
        end
        
        pred_std = std(predictions(1:3));
        errorbar(ax{3}, 4, Y_ensemble, pred_std, 'Color', [0.2, 0.2, 0.2], ...
                'LineWidth', 2, 'CapSize', 12);
        hold(ax{3}, 'off');
        
        ax{3}.XTick = 1:4;
        ax{3}.XTickLabel = {'SVR', 'GPR', 'RF', 'Ens'};
        ax{3}.YLabel.String = 'Predicted pH';
        ax{3}.YLabel.FontWeight = 'bold';
        grid(ax{3}, 'on');
        
        cla(ax{4});
        deviation = abs(X_input - app_data.mean_X) ./ (app_data.std_X + eps);
        
        hold(ax{4}, 'on');
        for i = 1:length(deviation)
            bar(ax{4}, i, deviation(i), 'FaceColor', bar_colors(i,:), ...
                'EdgeColor', bar_colors(i,:)*0.7, 'LineWidth', 1);
        end
        hold(ax{4}, 'off');
        
        ax{4}.XLabel.String = 'Feature Index';
        ax{4}.XLabel.FontWeight = 'bold';
        ax{4}.YLabel.String = 'Std Deviations';
        ax{4}.YLabel.FontWeight = 'bold';
        grid(ax{4}, 'on');
        
        cla(ax{5});
        if ~isempty(app_data.test_data) && length(app_data.test_data) > 10
            test_mean = mean(app_data.test_data);
            residuals = app_data.test_data - test_mean;
            
            scatter(ax{5}, app_data.test_data, residuals, 15, ...
                   c.nature(7,:), 'filled', 'MarkerFaceAlpha', 0.5);
            hold(ax{5}, 'on');
            plot(ax{5}, [min(app_data.test_data), max(app_data.test_data)], [0, 0], ...
                 '--', 'Color', [0.3, 0.3, 0.3], 'LineWidth', 2);
            scatter(ax{5}, Y_ensemble, Y_ensemble - test_mean, 100, ...
                   c.ensemble, 'filled', 'MarkerEdgeColor', c.ensemble*0.6, 'LineWidth', 2);
            hold(ax{5}, 'off');
            
            ax{5}.XLabel.String = 'Predicted Value';
            ax{5}.XLabel.FontWeight = 'bold';
            ax{5}.YLabel.String = 'Residual';
            ax{5}.YLabel.FontWeight = 'bold';
            legend(ax{5}, {'Test', 'Zero', 'Current'}, 'Location', 'best', 'Box', 'off', 'FontSize', 7);
        end
        grid(ax{5}, 'on');
        
        cla(ax{6});
        if ~isempty(app_data.history) && size(app_data.history, 1) > 0
            n = min(15, size(app_data.history, 1));
            hist_vals = zeros(n, 4);
            for i = 1:n
                hist_vals(i, :) = [app_data.history{end-n+i, 2:5}];
            end
            
            hold(ax{6}, 'on');
            plot(ax{6}, 1:n, hist_vals(:,1), '-o', 'Color', c.svr, ...
                 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', c.svr);
            plot(ax{6}, 1:n, hist_vals(:,2), '-s', 'Color', c.gpr, ...
                 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', c.gpr);
            plot(ax{6}, 1:n, hist_vals(:,3), '-^', 'Color', c.rf, ...
                 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', c.rf);
            plot(ax{6}, 1:n, hist_vals(:,4), '-d', 'Color', c.ensemble, ...
                 'LineWidth', 2.5, 'MarkerSize', 7, 'MarkerFaceColor', c.ensemble);
            hold(ax{6}, 'off');
            
            ax{6}.XLabel.String = 'Sequence';
            ax{6}.XLabel.FontWeight = 'bold';
            ax{6}.YLabel.String = 'pH';
            ax{6}.YLabel.FontWeight = 'bold';
            legend(ax{6}, {'SVR', 'GPR', 'RF', 'Ens'}, 'Location', 'best', 'Box', 'off', 'FontSize', 7);
        end
        grid(ax{6}, 'on');
    end
    
    function batchPrediction()
        if ~app_data.model_loaded
            uialert(fig, 'Please load model first!', 'Warning');
            return;
        end
        
        [file, path] = uigetfile({'*.csv;*.xlsx', 'Data Files'}, 'Select Batch File');
        if isequal(file, 0), return; end
        
        try
            batch_data = readmatrix(fullfile(path, file));
            
            if size(batch_data, 2) ~= length(app_data.mean_X)
                uialert(fig, sprintf('Expected %d features!', length(app_data.mean_X)), 'Error');
                return;
            end
            
            n_samples = size(batch_data, 1);
            results = zeros(n_samples, 5);
            
            for i = 1:n_samples
                X_norm = (batch_data(i,:) - app_data.mean_X) ./ app_data.std_X;
                
                Y_svr = predict(app_data.svr_model, X_norm) * app_data.std_Y + app_data.mean_Y;
                Y_gpr = predict(app_data.gpr_model, X_norm) * app_data.std_Y + app_data.mean_Y;
                Y_rf = predict(app_data.rf_model, X_norm);
                if iscell(Y_rf), Y_rf = str2double(Y_rf{1}); end
                
                Y_ens = app_data.weights(1)*Y_svr + app_data.weights(2)*Y_gpr + app_data.weights(3)*Y_rf;
                results(i,:) = [i, Y_svr, Y_gpr, Y_rf, Y_ens];
            end
            
            [save_file, save_path] = uiputfile('*.xlsx', 'Save Results', 'batch_results.xlsx');
            if ~isequal(save_file, 0)
                T = array2table(results, 'VariableNames', {'Sample', 'SVR', 'GPR', 'RF', 'Ensemble'});
                writetable(T, fullfile(save_path, save_file));
                uialert(fig, sprintf('Processed %d samples!', n_samples), 'Success', 'Icon', 'success');
            end
            
        catch ME
            uialert(fig, sprintf('Batch failed: %s', ME.message), 'Error');
        end
    end
    
    function exportResults()
        if isempty(app_data.history)
            uialert(fig, 'No history to export!', 'Warning');
            return;
        end
        
        [file, path] = uiputfile('*.xlsx', 'Save Results', 'prediction_history.xlsx');
        if isequal(file, 0), return; end
        
        try
            export_data = cell(size(app_data.history, 1) + 1, 6);
            export_data(1,:) = {'Timestamp', 'SVR', 'GPR', 'RF', 'Ensemble', 'Std'};
            
            for i = 1:size(app_data.history, 1)
                export_data{i+1, 1} = char(app_data.history{i, 1});
                export_data(i+1, 2:6) = num2cell([app_data.history{i, 2:6}]);
            end
            
            writecell(export_data, fullfile(path, file));
            uialert(fig, sprintf('Exported %d records!', size(app_data.history, 1)), ...
                   'Success', 'Icon', 'success');
            
        catch ME
            uialert(fig, sprintf('Export failed: %s', ME.message), 'Error');
        end
    end

end