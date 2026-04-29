function [opt_results, base_results] = optimization(forecast_demand, data)
    % 多目标优化调度模块
    % 对比传统人工策略与AI优化策略的运营效果
    
    % 换电站基础参数
    num_batteries = data.num_batteries;
    num_chargers = data.num_chargers;
    hours = length(forecast_demand);
    price = data.price(end-hours+1:end);
    
    % 电池技术参数
    battery_cap = 100; % 单块电池容量(kWh)
    charge_rate = 20;  % 充电功率(kW)
    min_soc = 0.2;     % 换电后最低SOC
    max_soc = 0.95;    % 充电截止SOC
    
    %% ====================== 基准策略：传统人工运营 ======================
    % 策略：电池换下来就充，充满为止，不考虑电价
    base_soc = ones(num_batteries, 1) * 0.5;
    base_charge_cost = 0;
    base_wait_time = 0;
    base_swaps = 0;
    
    for t = 1:hours
        demand = forecast_demand(t);
        available = sum(base_soc >= 0.5);
        
        % 计算用户等待时间（每缺1块电池等待10分钟）
        if demand > available
            base_wait_time = base_wait_time + (demand - available) * 10;
        end
        
        % 执行换电操作
        swap_num = min(demand, available);
        base_swaps = base_swaps + swap_num;
        [~, idx] = sort(base_soc, 'descend');
        base_soc(idx(1:swap_num)) = min_soc;
        
        % 充电策略：有空位就充
        charging = sum(base_soc < max_soc);
        charging = min(charging, num_chargers);
        [~, idx] = sort(base_soc);
        
        for i = 1:charging
            if base_soc(idx(i)) < max_soc
                base_soc(idx(i)) = min(base_soc(idx(i)) + charge_rate/battery_cap, max_soc);
                base_charge_cost = base_charge_cost + price(t) * charge_rate;
            end
        end
    end
    
    % 计算基准策略指标
    base_results.turnover = base_swaps / num_batteries / (hours/24);
    base_results.cost = base_charge_cost / (hours/24);
    base_results.wait_time = base_wait_time / hours;
    
    %% ====================== AI优化策略：智能分时充电 ======================
    % 策略：谷段多充、峰段少充，优先保证高峰时段电池供应
    opt_soc = ones(num_batteries, 1) * 0.5;
    opt_charge_cost = 0;
    opt_wait_time = 0;
    opt_swaps = 0;
    opt_charge_schedule = zeros(num_batteries, hours);
    
    for t = 1:hours
        demand = forecast_demand(t);
        current_price = price(t);
        
        % 1. 优先执行换电操作
        available = sum(opt_soc >= 0.5);
        if demand > available
            opt_wait_time = opt_wait_time + (demand - available) * 10;
        end
        swap_num = min(demand, available);
        opt_swaps = opt_swaps + swap_num;
        [~, idx] = sort(opt_soc, 'descend');
        opt_soc(idx(1:swap_num)) = min_soc;
        
        % 2. 智能充电决策：根据电价调整充电强度
        if current_price < 0.6 % 谷段/平段：满功率充电
            charge_slots = num_chargers;
        else % 峰段：仅充30%的空位，保留电量给谷段
            charge_slots = round(num_chargers * 0.3);
        end
        
        [~, idx] = sort(opt_soc);
        for i = 1:charge_slots
            if opt_soc(idx(i)) < max_soc
                opt_soc(idx(i)) = min(opt_soc(idx(i)) + charge_rate/battery_cap, max_soc);
                opt_charge_cost = opt_charge_cost + current_price * charge_rate;
                opt_charge_schedule(idx(i), t) = 1;
            end
        end
    end
    
    % 计算优化策略指标
    opt_results.turnover = opt_swaps / num_batteries / (hours/24);
    opt_results.cost = opt_charge_cost / (hours/24);
    opt_results.wait_time = opt_wait_time / hours;
    opt_results.charge_schedule = opt_charge_schedule;
end
