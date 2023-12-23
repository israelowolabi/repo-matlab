%Run the simulation first before this script
plot_combined(cstr2_sim_data.cstr2_data);
function plot_combined(cstr2_data)
    LW = 1.5;
    x1_enmpc = cstr2_data.signals(1).values(:,1);
    x1_ss = cstr2_data.signals(1).values(:,2);
    x2_enmpc = cstr2_data.signals(2).values(:,1);
    x2_ss = cstr2_data.signals(2).values(:,2);
    x3_enmpc = cstr2_data.signals(3).values(:,1);
    x3_ss = cstr2_data.signals(3).values(:,2);
    u_enmpc = cstr2_data.signals(4).values(:,1);
    u_ss = cstr2_data.signals(4).values(:,2);
    time = cstr2_data.time;

    f1 = figure(1);
        x1_plot()
        save_fig(f1,'x1');
        
    f2 = figure(2);
        x2_plot()
        save_fig(f2,'x2');
        
    f3 = figure(3);
        x3_plot()
        save_fig(f3,'x3');
  
    f4 = figure(4);
        u_plot()
        save_fig(f4,'u');

    f5 = figure(5);
        subplot(2,2,1)
            x1_plot()
        subplot(2,2,2)
            x2_plot()
        subplot(2,2,3)
            x3_plot()
        subplot(2,2,4)
            u_plot()
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
    function x1_plot()
        plot(time,x1_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,x1_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('x1')
        grid on
        legend('ENMPC', 'SS')
    end
    function x2_plot()
        plot(time,x2_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,x2_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('x2')
        grid on
        legend('ENMPC', 'SS')
    end
    function x3_plot()
        plot(time,x3_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,x3_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('x3')
        grid on
        legend('ENMPC', 'SS')
    end
    function u_plot()
        plot(time,u_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,u_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('u')
        grid on
        legend('ENMPC', 'SS')
    end
end