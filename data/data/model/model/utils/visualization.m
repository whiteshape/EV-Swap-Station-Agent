function visualization(time, forecast, actual, opt_results, base_results, accuracy)
    % 结果可视化绘图模块
    % 生成3张核心结果图表
    
    test_time = time(end-length(actual)+1:end);
    
    %% 图1：LSTM需求预测结果对比
    figure('Position', [100, 100, 1000, 400]);
    plot(test_time, actual, 'b-', 'LineWidth', 1.5, 'DisplayName', '实际换电需求');
    hold on;
    plot(test_time, forecast, 'r--', 'LineWidth', 1.5, 'DisplayName', ['LSTM预测 (准确率: ', num2str(accuracy*100, '%.1f'), '%)']);
    xlabel('时间'); ylabel('小时换电次数');
    title('工业园区换电站LSTM需求预测结果');
    legend('Location', 'best');
    grid on;
    datetick('x', 'mm-dd HH');
    
    %% 图2：优化前后核心运营指标对比
    figure('Position', [100, 100, 1000, 400]);
    
    metrics = {'电池日均周转次数', '日均充电成本(元)', '高峰平均等待时间(分钟)'};
    base_vals = [base_results.turnover, base_results.cost, base_results.wait_time];
    opt_vals = [opt_results.turnover, opt_results.cost, opt_results.wait_time];
    
    bar([base_vals; opt_vals]');
    set(gca, 'XTickLabel', metrics);
    ylabel('指标数值');
    title('AI Agent优化前后核心运营指标对比');
    legend('传统人工策略', 'AI智能优化策略', 'Location', 'best');
    grid on;
    
    % 在柱状图上标注数值
    text(0.85, base_vals(1)+0.1, num2str(base_vals(1), '%.1f'), 'HorizontalAlignment', 'center');
    text(1.15, opt_vals(1)+0.1, num2str(opt_vals(1), '%.1f'), 'HorizontalAlignment', 'center');
    text(1.85, base_vals(2)+5, num2str(base_vals(2), '%.0f'), 'HorizontalAlignment', 'center');
    text(2.15, opt_vals(2)+5, num2str(opt_vals(2), '%.0f'), 'HorizontalAlignment', 'center');
    text(2.85, base_vals(3)+1, num2str(base_vals(3), '%.0f'), 'HorizontalAlignment', 'center');
    text(3.15, opt_vals(3)+1, num2str(opt_vals(3), '%.0f'), 'HorizontalAlignment', 'center');
    
    %% 图3：最后24小时充电计划示意
    figure('Position', [100, 100, 1000, 400]);
    last_24_time = test_time(end-23:end);
    
    subplot(2,1,1);
    plot(last_24_time, actual(end-23:end), 'k-o', 'LineWidth', 1.5);
    title('最后24小时换电需求与电池充电计划');
    ylabel('换电次数');
    grid on;
    datetick('x', 'HH:00');
    
    subplot(2,1,2);
    stairs(last_24_time, opt_results.charge_schedule(1:5, end-23:end)', 'LineWidth', 1.2);
    xlabel('时间'); ylabel('充电状态(1=充电中)');
    legend('电池1', '电池2', '电池3', '电池4', '电池5', 'Location', 'best');
    grid on;
    datetick('x', 'HH:00');
end
