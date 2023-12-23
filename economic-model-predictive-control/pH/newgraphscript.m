
LW = 2;
y_set = out.y.signals.values(:,1);
y_enmpc = out.y.signals.values(:,2);
y_nmpc = out.y.signals.values(:,3);
u_enmpc = out.u.signals.values(:,1);
u_nmpc = out.u.signals.values(:,2);
d = out.d.signals.values(:,1);
cost_enmpc = out.c.signals.values(:,1);
cost_nmpc = out.c.signals.values(:,2);
% time = pH_data.time;

subplot(2,2,1)
plot(out.y.time,y_enmpc,'g-','LineWidth',LW)
hold on
plot(out.y.time,y_nmpc,'b-','LineWidth',LW)
hold on
plot(out.y.time,y_set,'r--','LineWidth',LW)
xlabel('Time (s)')
ylabel('pH')
grid on
legend('ENMPC', 'NMPC', 'Setpoint')

subplot(2,2,2)
plot(out.u.time,u_enmpc,'r-','LineWidth',LW)
hold on
plot(out.u.time,u_nmpc,'b-','LineWidth',LW)
xlabel('Time (s)')
ylabel('q_3 (ml/s)')
grid on
legend('ENMPC', 'NMPC')


subplot(2,2,3)
plot(out.d.time,d,'k-','LineWidth',LW)
xlabel('Time (s)')
ylabel('q_2  (ml/s)')
grid on

subplot(2,2,4)
plot(out.c.time,cost_enmpc,'r-','LineWidth',LW)
hold on
plot(out.c.time,cost_nmpc,'b-','LineWidth',LW)
xlabel('Time (s)')
ylabel('cost')
grid on
legend('ENMPC', 'NMPC')
