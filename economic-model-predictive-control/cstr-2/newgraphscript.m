
LW = 2;
x1_enmpc = cstr2_sim_data.cstr2_data.signals(1).values(:,1);
x1_ss = cstr2_sim_data.cstr2_data.signals(1).values(:,2);
x2_enmpc = cstr2_sim_data.cstr2_data.signals(2).values(:,1);
x2_ss = cstr2_sim_data.cstr2_data.signals(2).values(:,2);
x3_enmpc = cstr2_sim_data.cstr2_data.signals(3).values(:,1);
x3_ss = cstr2_sim_data.cstr2_data.signals(3).values(:,2);
u_enmpc = cstr2_sim_data.cstr2_data.signals(4).values(:,1);
u_ss = cstr2_sim_data.cstr2_data.signals(4).values(:,2);
time = cstr2_sim_data.cstr2_data.time;

subplot(2,2,1)
plot(time,x1_enmpc,'b-','LineWidth',LW)
hold on
plot(time,x1_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
ylabel('x1')
grid on
legend('ENMPC', 'NMPC')

subplot(2,2,2)
plot(time,x2_enmpc,'b-','LineWidth',LW)
hold on
plot(time,x2_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
ylabel('x2')
grid on
legend('ENMPC', 'NMPC')


subplot(2,2,3)
plot(time,x3_enmpc,'b-','LineWidth',LW)
hold on
plot(time,x3_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
ylabel('x3')
grid on
legend('ENMPC', 'NMPC')

subplot(2,2,4)
plot(time,u_enmpc,'b-','LineWidth',LW)
hold on
plot(time,u_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
ylabel('u')
grid on
legend('ENMPC', 'NMPC')
