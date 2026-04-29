function [data, time] = generate_data()
    % 生成工业园区45天的小时级模拟数据
    % 包含：换电需求、电网电价、充电桩状态
    
    days = 45;
    hours = days * 24;
    time = datetime(2026,3,1,0,0,0) + hours(0:hours-1);
    
    % 1. 生成换电需求（工业园区早晚高峰模式）
    demand = zeros(hours, 1);
    for d = 1:days
        idx = (d-1)*24 + 1 : d*24;
        % 早高峰 8:00-10:00（物流车入园高峰）
        demand(idx(8:10)) = 15 + 5*randn(3,1);
        % 晚高峰 17:00-19:00（物流车离园高峰）
        demand(idx(17:19)) = 18 + 6*randn(3,1);
        % 平段时段
        demand(idx([1:7,11:16,20:24])) = 5 + 2*randn(18,1);
    end
    demand = max(demand, 0); % 非负处理
    
    % 2. 生成电网峰谷平电价（湖北工业用电标准）
    price = zeros(hours, 1);
    for d = 1:days
        idx = (d-1)*24 + 1 : d*24;
        price(idx(1:7)) = 0.3;   % 谷段 00:00-07:00
        price(idx(8:11)) = 1.2;  % 峰段 08:00-11:00
        price(idx(12:14)) = 0.8; % 平段 12:00-14:00
        price(idx(15:19)) = 1.2; % 峰段 15:00-19:00
        price(idx(20:24)) = 0.5; % 谷段 20:00-24:00
    end
    
    % 3. 换电站基础参数
    data.demand = demand;
    data.price = price;
    data.num_batteries = 28; % 标准换电站电池配置
    data.num_chargers = 10;  % 充电桩数量
end
