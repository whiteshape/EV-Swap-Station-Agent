function [forecast, actual, accuracy] = demand_forecast(data)
    % LSTM多尺度需求预测模块
    % 输入：历史换电需求数据
    % 输出：未来24小时预测值、实际值、预测准确率
    
    demand = data.demand;
    hours = length(demand);
    
    % 数据集划分：前40天训练，最后5天测试
    train_hours = 40*24;
    test_hours = 5*24;
    
    % 数据归一化
    [demand_norm, mu, sigma] = normalize(demand(1:train_hours));
    
    % 构建LSTM输入序列（用过去24小时预测未来1小时）
    seq_length = 24;
    X_train = []; Y_train = [];
    for i = seq_length : train_hours-1
        X_train = cat(3, X_train, demand_norm(i-seq_length+1:i));
        Y_train = cat(2, Y_train, demand_norm(i+1));
    end
    
    % 构建LSTM网络架构
    layers = [ ...
        sequenceInputLayer(1)
        lstmLayer(64, 'OutputMode', 'last')
        dropoutLayer(0.2)
        fullyConnectedLayer(1)
        regressionLayer ];
    
    % 训练选项（静默模式，避免输出过多信息）
    options = trainingOptions('adam', ...
        'MaxEpochs', 50, ...
        'MiniBatchSize', 32, ...
        'Verbose', false, ...
        'Plots', 'none');
    
    % 训练模型
    net = trainNetwork(X_train, Y_train, layers, options);
    
    % 测试集预测
    X_test = []; 
    actual = demand(train_hours+1:end);
    test_demand_norm = normalize(demand(train_hours-seq_length+1:end), 'center', mu, 'scale', sigma);
    
    for i = seq_length : length(test_demand_norm)-1
        X_test = cat(3, X_test, test_demand_norm(i-seq_length+1:i));
    end
    
    forecast_norm = predict(net, X_test);
    forecast = forecast_norm * sigma + mu;
    forecast = max(forecast, 0); % 预测值非负处理
    
    % 计算平均绝对百分比准确率
    accuracy = 1 - mean(abs(forecast - actual)) / mean(actual);
end
