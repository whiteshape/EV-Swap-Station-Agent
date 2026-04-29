%% 工业园区换电站AI运营优化Agent - 主程序
% 作者：白相
% 日期：2026-04-29

clc; clear; close all;
fprintf('========================================\n');
fprintf('  工业园区换电站AI运营优化Agent启动\n');
fprintf('========================================\n\n');

%% 1. 生成模拟数据
fprintf('[1/5] 正在生成工业园区模拟换电数据...\n');
[data, time] = generate_data();
fprintf('      数据生成完成！共 %d 天小时级数据\n\n', length(data)/24);

%% 2. LSTM需求预测
fprintf('[2/5] 正在训练LSTM需求预测模型...\n');
[forecast_demand, actual_demand, forecast_accuracy] = demand_forecast(data);
fprintf('      模型训练完成！预测准确率：%.1f%%\n\n', forecast_accuracy*100);

%% 3. 优化调度求解
fprintf('[3/5] 正在求解多目标优化调度方案...\n');
[opt_results, base_results] = optimization(forecast_demand, data);
fprintf('      优化方案求解完成！\n\n');

%% 4. 结果可视化
fprintf('[4/5] 正在生成结果可视化图表...\n');
visualization(time, forecast_demand, actual_demand, opt_results, base_results, forecast_accuracy);
fprintf('      图表生成完成！\n\n');

%% 5. 输出量化指标
fprintf('[5/5] 优化效果量化分析：\n');
fprintf('  - 电池日均周转次数：%.1f -> %.1f (提升 %.1f%%)\n', ...
    base_results.turnover, opt_results.turnover, (opt_results.turnover-base_results.turnover)/base_results.turnover*100);
fprintf('  - 日均充电成本：%.2f元 -> %.2f元 (降低 %.1f%%)\n', ...
    base_results.cost, opt_results.cost, (base_results.cost-opt_results.cost)/base_results.cost*100);
fprintf('  - 高峰平均等待时间：%.1f分钟 -> %.1f分钟 (缩短 %.1f%%)\n', ...
    base_results.wait_time, opt_results.wait_time, (base_results.wait_time-opt_results.wait_time)/base_results.wait_time*100);
fprintf('\n========================================\n');
fprintf('  所有任务执行完毕！\n');
fprintf('========================================\n');
