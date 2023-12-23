LW = 1.5;

subplot(2,1,1)
plot(out.asave.time(:,1), out.asave.signals.values(:,1),'g-','Linewidth', LW )
hold on
plot(out.asave.time(:,1), out.asave.signals.values(:,2),'b-','Linewidth', LW )
hold on
plot(out.asave.time(:,1), out.asave.signals.values(:,3),'r-','Linewidth', LW )
hold on
plot(out.asave.time(:,1), out.asave.signals.values(:,4),'k--','Linewidth', LW )
hold off
xlabel('Time (s)')
xlim([0 120])
ylabel('Ca (mol/L)')
ylim([0 0.15])
grid on
legend('Non-Adaptive LMPC','Successive Linearization', 'linear parameter varying system','setpoint')
title('(a)')

subplot(2,1,2)
plot(out.bsave.time(:,1), out.bsave.signals.values(:,1),'g-','Linewidth', LW )
hold on
plot(out.bsave.time(:,1), out.bsave.signals.values(:,2),'b-','Linewidth', LW )
hold on
plot(out.bsave.time(:,1), out.bsave.signals.values(:,3),'r-','Linewidth', LW )
hold on
plot(out.bsave.time(:,1), out.bsave.signals.values(:,4),'k--','Linewidth', LW )
hold off
xlabel('Time (s)')
xlim([0 120])
ylabel('T (K)')
ylim([420 490])
grid on
legend('Non-Adaptive LMPC','Successive Linearization', 'linear parameter varying system', 'setpoint')
title('(b)')