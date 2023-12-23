%Run the simulation first before this script
plot_combined(cstr_sim_data.cstr_data);
function plot_combined(cstr_data)
    LW = 1.5;
    x1_enmpc = cstr_data.signals(1).values(:,1);
    x1_ss = cstr_data.signals(1).values(:,2);
    x2_enmpc = cstr_data.signals(2).values(:,1);
    x2_ss = cstr_data.signals(2).values(:,2);
    x3_enmpc = cstr_data.signals(3).values(:,1);
    x3_ss = cstr_data.signals(3).values(:,2);
    x4_enmpc = cstr_data.signals(4).values(:,1);
    x4_ss = cstr_data.signals(4).values(:,2);
    u1_enmpc = cstr_data.signals(5).values(:,1);
    u1_ss = cstr_data.signals(5).values(:,2);
    u2_enmpc = cstr_data.signals(6).values(:,1);
    u2_ss = cstr_data.signals(6).values(:,2);
    time = cstr_data.time;

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
        x4_plot()
        save_fig(f4,'x4');
        
    f5 = figure(5);
        u1_plot()
        save_fig(f5,'u1');
        
    f6 = figure(6);
        u2_plot()
        save_fig(f6,'u2');

    f7 = figure(7);
        subplot(2,3,1)
            x1_plot()
        subplot(2,3,2)
            x2_plot()
        subplot(2,3,3)
            x3_plot()
        subplot(2,3,4)
            x4_plot()
        subplot(2,3,5)
            u1_plot()
        subplot(2,3,6)
            u2_plot()
        save_fig(f7,'combined');
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
    function x4_plot()
        plot(time,x4_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,x4_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('x4')
        grid on
        legend('ENMPC', 'SS')
    end
    function u1_plot()
        plot(time,u1_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,u1_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('u1')
        grid on
        legend('ENMPC', 'SS')
    end
    function u2_plot()
        plot(time,u2_enmpc,'k-','LineWidth',LW)
        hold on
        plot(time,u2_ss,'r--','LineWidth',LW)
        xlabel('Time (s)')
        ylabel('u2')
        grid on
        legend('ENMPC', 'SS')
    end
end