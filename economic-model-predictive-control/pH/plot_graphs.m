%Run the simulation first before this script
plot_combined(out.pH_data);
function plot_combined(pH_data)
    LW = 1.5;
    y_set = pH_data.signals(1).values(:,1);
    y_enmpc = pH_data.signals(1).values(:,2);
    y_nmpc = pH_data.signals(1).values(:,3);
    u_enmpc = pH_data.signals(2).values(:,1);
    u_nmpc = pH_data.signals(2).values(:,2);
    d = pH_data.signals(3).values(:,1);
    cost_enmpc = pH_data.signals(4).values(:,1);
    cost_nmpc = pH_data.signals(4).values(:,2);
    time = pH_data.time;

    f1 = figure(1);
        y_plot()
        save_fig(f1,'y');
        
    f2 = figure(2);
        u_plot()
        save_fig(f2,'u');
        
    f3 = figure(3);
        d_plot()
        save_fig(f3,'d');
  
    f4 = figure(4);
        cost_plot()
        save_fig(f4,'cost');

    f5 = figure(5);
        subplot(2,2,1)
            y_plot()
        subplot(2,2,2)
            u_plot()
        subplot(2,2,3)
            d_plot()
        subplot(2,2,4)
            cost_plot()
        save_fig(f5,'combined');
    function save_fig(fh,name)
       set(findall(fh,'Units','pixels'),'Units','normalized');
       fh.Units = 'pixels';
       res = 600;
       base_pos = [0, 0, res*8.3, res*11.7];
       fh.OuterPosition = base_pos;
       set(fh,'PaperPositionMode','manual');
       fh.PaperUnits = 'inches';
       fh.PaperPosition = base_pos/res;
       print(fh,name,'-dpng',sprintf('-r%d',res))
    end
    function y_plot()
        plot(time,y_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,y_nmpc,'b-','LineWidth',LW)
        hold on
        plot(time,y_set,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('pH')
        grid on
        legend('ENMPC', 'NMPC', 'Setpoint')
    end
    function u_plot()
        plot(time,u_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,u_nmpc,'b-','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('q_3 (ml/s)')
        grid on
        legend('ENMPC', 'NMPC')
    end
    function d_plot()
        plot(time,d,'k-','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('q_2  (ml/s)')
        grid on
    end
    function cost_plot()
       plot(time,cost_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,cost_nmpc,'b-','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('cost')
        grid on
        legend('ENMPC', 'NMPC')
    end
end