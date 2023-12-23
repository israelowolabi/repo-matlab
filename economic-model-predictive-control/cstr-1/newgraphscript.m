
LW = 2;
x1_enmpc = out.x1.signals.values(:,1);
x1_ss = out.x1.signals.values(:,2);
x2_enmpc = out.x2.signals.values(:,1);
x2_ss = out.x2.signals.values(:,2);
x3_enmpc = out.x3.signals.values(:,1);
x3_ss = out.x3.signals.values(:,2);
x4_enmpc = out.x4.signals.values(:,1);
x4_ss = out.x4.signals.values(:,2);
u1_enmpc = out.u1.signals.values(:,1);
u1_ss = out.u1.signals.values(:,2);
u2_enmpc = out.u2.signals.values(:,1);
u2_ss = out.u2.signals.values(:,2);

subplot(2,3,1)
plot(out.x1.time,x1_enmpc,'b-','LineWidth',LW)
hold on
plot(out.x1.time,x1_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
xlim([0 450])
ylabel('x1')
grid on
legend('ENMPC', 'NMPC')

subplot(2,3,2)
plot(out.x2.time,x2_enmpc,'b-','LineWidth',LW)
hold on
plot(out.x2.time,x2_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
xlim([0 450])
ylabel('x2')
grid on
legend('ENMPC', 'NMPC')

subplot(2,3,3)
plot(out.x3.time,x3_enmpc,'b-','LineWidth',LW)
hold on
plot(out.x3.time,x3_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
xlim([0 450])
ylabel('x3')
grid on
legend('ENMPC', 'NMPC')

subplot(2,3,4)
plot(out.x4.time,x4_enmpc,'b-','LineWidth',LW)
hold on
plot(out.x4.time,x4_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
xlim([0 450])
ylabel('x4')
grid on
legend('ENMPC', 'NMPC')

subplot(2,3,5)
plot(out.u1.time,u1_enmpc,'b-','LineWidth',LW)
hold on
plot(out.u1.time,u1_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
xlim([0 450])
ylabel('u1')
grid on
legend('ENMPC', 'NMPC')

subplot(2,3,6)
plot(out.u2.time,u2_enmpc,'b-','LineWidth',LW)
hold on
plot(out.u2.time,u2_ss,'r--','LineWidth',LW)
xlabel('Time (s)')
xlim([0 450])
ylabel('u2')
grid on
legend('ENMPC', 'NMPC')

