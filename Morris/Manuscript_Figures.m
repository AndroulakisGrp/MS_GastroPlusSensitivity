%% Generate figures for APAP

Labels_APAP={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Pore Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Pore Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejunum 1 Porosity/Pore Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Pore Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Pore Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Pore Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Pore Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Pore Length',' Caecum Transit Time',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Pore Length', 'Colon Transit Time',...
            'Small Intestine Fasted Fluid Volume', 'Colon Fasted Fluid Volume','Small Intestine Length','Small Intestine Radius','Small Intestine Transit Time',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','Whole Blood to Plasma Ratio', 'Fraction of Unbound Protein','Central Compartment Volume','Transfer Coefficient, k12','Transfer Coefficient, k21',...
            'Systemic Clearance','Renal Clearance'};
 
reordered_mu_star=vertcat(func_mu_star_SigFig(1:39,:),func_mu_star_SigFig(41:43,:),func_mu_star_SigFig(51:54,:),func_mu_star_SigFig(40,:),func_mu_star_SigFig(44:46,:),func_mu_star_SigFig(48:50,:),func_mu_star_SigFig(47,:),func_mu_star_SigFig(55,:));
reordered_mu=vertcat(func_mu_SigFig(1:39,:),func_mu_SigFig(41:43,:),func_mu_SigFig(51:54,:),func_mu_SigFig(40,:),func_mu_SigFig(44:46,:),func_mu_SigFig(48:50,:),func_mu_SigFig(47,:),func_mu_SigFig(55,:));
reordered_sigma=vertcat(func_sigma_SigFig(1:39,:),func_sigma_SigFig(41:43,:),func_sigma_SigFig(51:54,:),func_sigma_SigFig(40,:),func_sigma_SigFig(44:46,:),func_sigma_SigFig(48:50,:),func_sigma_SigFig(47,:),func_sigma_SigFig(55,:));
  
figure
subplot(2,1,1)
bar(reordered_mu_star(:,1),'EdgeColor','k','FaceColor','g')
hold on
hline=refline([0 Cutoff_Mu_Star_Cmax]);
hline.Color='red';
hline.LineStyle='--';
title('(A) Acetaminophen C_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 56];
%ax.YLim = [0 20];
hold off
 
subplot(2,1,2)
bar(reordered_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on 
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(A) Acetaminophen t_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 56];
%ax.YLim = [0 4];
hold off
 
figure
subplot(2,1,1)
bar(reordered_mu_star(:,3),'EdgeColor','k','FaceColor','r')
hold on
hline=refline(0,Cutoff_Mu_Star_AUC)
hline.Color='red';
hline.LineStyle='--';
title('(C) Acetaminophen AUC_{0-t}','Color','black','FontSize',14)
set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 56];
hold off


% figure
% subplot(2,1,1)
% bar(reordered_mu(:,1),'EdgeColor','k','FaceColor','g')
% title('(A) \mu for Acetaminophen C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 56];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,1),'EdgeColor','k','FaceColor','g')
% title('(B) \sigma^2 for Acetaminophen C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 56];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,2),'EdgeColor','k','FaceColor','b')
% title('(A) \mu for Acetaminophen t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=12;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 56];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,2),'EdgeColor','k','FaceColor','b')
% title('(B) \sigma^2 for Acetaminophen t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 56];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,3),'EdgeColor','k','FaceColor','r')
% title('(A) \mu for Acetaminophen AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 56];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,3),'EdgeColor','k','FaceColor','r')
% title('(B) \sigma^2 for Acetaminophen AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:55, 'XTickLabel', Labels_APAP,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 56];

%% Generate figures for Risperidone

Labels_Risp={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Pore Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Pore Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejunum 1 Porosity/Pore Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Pore Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Pore Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Pore Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Pore Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Pore Length',' Caecum Transit Time',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Pore Length', 'Colon Transit Time',...
            'Small Intestine Fasted Fluid Volume', 'Colon Fasted Fluid Volume','Small Intestine Length','Small Intestine Radius','Small Intestine Transit Time',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','Whole Blood to Plasma Ratio', 'Fraction of Unbound Plasma Protein','Central Compartment Volume','Transfer Coefficient, k12','Transfer Coefficient, k21','Transfer Coefficient, k13','Transfer Coefficient, k31',...
            'Systemic Clearance','Liver First-pass Extraction'};
        
reordered_mu_star=vertcat(func_mu_star_SigFig(1:39,:),func_mu_star_SigFig(41:43,:),func_mu_star_SigFig(53:56,:),func_mu_star_SigFig(40,:),func_mu_star_SigFig(44:46,:),func_mu_star_SigFig(48:52,:),func_mu_star_SigFig(47,:),func_mu_star_SigFig(57,:));
reordered_mu=vertcat(func_mu_SigFig(1:39,:),func_mu_SigFig(41:43,:),func_mu_SigFig(53:56,:),func_mu_SigFig(40,:),func_mu_SigFig(44:46,:),func_mu_SigFig(48:52,:),func_mu_SigFig(47,:),func_mu_SigFig(57,:));
reordered_sigma=vertcat(func_sigma_SigFig(1:39,:),func_sigma_SigFig(41:43,:),func_sigma_SigFig(53:56,:),func_sigma_SigFig(40,:),func_sigma_SigFig(44:46,:),func_sigma_SigFig(48:52,:),func_sigma_SigFig(47,:),func_sigma_SigFig(57,:));
  
figure
subplot(2,1,1)
bar(reordered_mu_star(:,1),'EdgeColor','k','FaceColor','g')
hold on
hline=refline([0 Cutoff_Mu_Star_Cmax]);
hline.Color='red';
hline.LineStyle='--';
title('(A) Risperidone C_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 58];
%ax.YLim = [0 20];
hold off
 
subplot(2,1,2)
bar(reordered_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on 
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(A) Risperidone t_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];
%ax.YLim = [0 4];
hold off
 
figure
subplot(2,1,1)
bar(reordered_mu_star(:,3),'EdgeColor','k','FaceColor','r')
hold on
hline=refline(0,Cutoff_Mu_Star_AUC)
hline.Color='red';
hline.LineStyle='--';
title('(C) Risperidone AUC_{0-t}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 58];
hold off


% figure
% subplot(2,1,1)
% bar(reordered_mu(:,1),'EdgeColor','k','FaceColor','g')
% title('(A) \mu for Risperidone C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 58];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,1),'EdgeColor','k','FaceColor','g')
% title('(B) \sigma^2 for Risperidone C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 58];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,2),'EdgeColor','k','FaceColor','b')
% title('(A) \mu for Risperidone t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=12;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 58];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,2),'EdgeColor','k','FaceColor','b')
% title('(B) \sigma^2 for Risperidone t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 58];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,3),'EdgeColor','k','FaceColor','r')
% title('(A) \mu for Risperidone AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 58];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,3),'EdgeColor','k','FaceColor','r')
% title('(B) \sigma^2 for Risperidone AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 58];

%% Generate figures for Atenolol

Labels_Aten={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Pore Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Pore Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejunum 1 Porosity/Pore Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Pore Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Pore Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Pore Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Pore Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Pore Length',' Caecum Transit Time',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Pore Length', 'Colon Transit Time',...
            'Small Intestine Fasted Fluid Volume', 'Colon Fasted Fluid Volume','Small Intestine Length','Small Intestine Radius','Small Intestine Transit Time',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','Whole Blood to Plasma Ratio', 'Fraction of Unbound Plasma Protein','Central Compartment Volume','Transfer Coefficient, k12','Transfer Coefficient, k21',...
            'Systemic Clearance'};

reordered_mu_star=vertcat(func_mu_star_SigFig(1:39,:),func_mu_star_SigFig(41:43,:),func_mu_star_SigFig(51:54,:),func_mu_star_SigFig(40,:),func_mu_star_SigFig(44:46,:),func_mu_star_SigFig(48:50,:),func_mu_star_SigFig(47,:));
reordered_mu=vertcat(func_mu_SigFig(1:39,:),func_mu_SigFig(41:43,:),func_mu_SigFig(51:54,:),func_mu_SigFig(40,:),func_mu_SigFig(44:46,:),func_mu_SigFig(48:50,:),func_mu_SigFig(47,:));
reordered_sigma=vertcat(func_sigma_SigFig(1:39,:),func_sigma_SigFig(41:43,:),func_sigma_SigFig(51:54,:),func_sigma_SigFig(40,:),func_sigma_SigFig(44:46,:),func_sigma_SigFig(48:50,:),func_sigma_SigFig(47,:));
  
figure
subplot(2,1,1)
bar(reordered_mu_star(:,1),'EdgeColor','k','FaceColor','g')
hold on
hline=refline([0 Cutoff_Mu_Star_Cmax]);
hline.Color='red';
hline.LineStyle='--';
title('(A) Atenolol C_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 55];
%ax.YLim = [0 20];
hold off
 
subplot(2,1,2)
bar(reordered_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on 
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(B) Atenolol t_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 55];
%ax.YLim = [0 4];
hold off
 
figure
subplot(2,1,1)
bar(reordered_mu_star(:,3),'EdgeColor','k','FaceColor','r')
hold on
hline=refline(0,Cutoff_Mu_Star_AUC)
hline.Color='red';
hline.LineStyle='--';
title('(C) Atenolol AUC_{0-t}','Color','black','FontSize',14)
set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 55];
hold off

% figure
% subplot(2,1,1)
% bar(reordered_mu(:,1),'EdgeColor','k','FaceColor','g')
% title('(A) \mu for Atenolol C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 55];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,1),'EdgeColor','k','FaceColor','g')
% title('(B) \sigma^2 for Atenolol C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 55];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,2),'EdgeColor','k','FaceColor','b')
% title('(A) \mu for Atenolol t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=12;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 55];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,2),'EdgeColor','k','FaceColor','b')
% title('(B) \sigma^2 for Atenolol t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 55];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,3),'EdgeColor','k','FaceColor','r')
% title('(A) \mu for Atenolol AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 55];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,3),'EdgeColor','k','FaceColor','r')
% title('(B) \sigma^2 for Atenolol AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:54, 'XTickLabel', Labels_Aten,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 55];

%% Generate figures for Furosemide

Labels_Fur={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Pore Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Pore Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejunum 1 Porosity/Pore Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Pore Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Pore Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Pore Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Pore Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Pore Length',' Caecum Transit Time',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Pore Length', 'Colon Transit Time',...
            'Small Intestine Fasted Fluid Volume', 'Colon Fasted Fluid Volume','Small Intestine Length','Small Intestine Radius','Small Intestine Transit Time',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','Whole Blood to Plasma Ratio', 'Fraction of Unbound Plasma Protein','Central Compartment Volume','Transfer Coefficient, k12','Transfer Coefficient, k21','Transfer Coefficient, k13','Transfer Coefficient, k31',...
            'Systemic Clearance','Renal Clearance'};
 
reordered_mu_star=vertcat(func_mu_star_SigFig(1:39,:),func_mu_star_SigFig(41:43,:),func_mu_star_SigFig(51:54,:),func_mu_star_SigFig(40,:),func_mu_star_SigFig(44:46,:),func_mu_star_SigFig(48:50,:),func_mu_star_SigFig(56:57,:),func_mu_star_SigFig(47,:),func_mu_star_SigFig(55,:));
reordered_mu=vertcat(func_mu_SigFig(1:39,:),func_mu_SigFig(41:43,:),func_mu_SigFig(51:54,:),func_mu_SigFig(40,:),func_mu_SigFig(44:46,:),func_mu_SigFig(48:50,:),func_mu_SigFig(56:57,:),func_mu_SigFig(47,:),func_mu_SigFig(55,:));
reordered_sigma=vertcat(func_sigma_SigFig(1:39,:),func_sigma_SigFig(41:43,:),func_sigma_SigFig(51:54,:),func_sigma_SigFig(40,:),func_sigma_SigFig(44:46,:),func_sigma_SigFig(48:50,:),func_sigma_SigFig(56:57,:),func_sigma_SigFig(47,:),func_sigma_SigFig(55,:));
  
figure
subplot(2,1,1)
bar(reordered_mu_star(:,1),'EdgeColor','k','FaceColor','g')
hold on
hline=refline([0 Cutoff_Mu_Star_Cmax]);
hline.Color='red';
hline.LineStyle='--';
title('(A) Furosemide C_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 58];
%ax.YLim = [0 20];
hold off
 
subplot(2,1,2)
bar(reordered_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on 
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(B) Furosemide t_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];
%ax.YLim = [0 4];
hold off
 
figure
subplot(2,1,1)
bar(reordered_mu_star(:,3),'EdgeColor','k','FaceColor','r')
hold on
hline=refline(0,Cutoff_Mu_Star_AUC)
hline.Color='red';
hline.LineStyle='--';
title('(C) Furosemide AUC_{0-t}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 60;
ax.XLim = [0 58];
hold off


% figure
% subplot(2,1,1)
% bar(reordered_mu(:,1),'EdgeColor','k','FaceColor','g')
% title('(A) \mu for Furosemide C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 58];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,1),'EdgeColor','k','FaceColor','g')
% title('(B) \sigma^2 for Furosemide C_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 58];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,2),'EdgeColor','k','FaceColor','b')
% title('(A) \mu for Furosemide t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=12;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 58];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,2),'EdgeColor','k','FaceColor','b')
% title('(B) \sigma^2 for Furosemide t_{max}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 58];
% 
% figure
% subplot(2,1,1)
% bar(reordered_mu(:,3),'EdgeColor','k','FaceColor','r')
% title('(A) \mu for Furosemide AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\mu';
% ax.YLabel.FontWeight='bold';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.XLim = [0 58];
% 
% subplot(2,1,2)
% bar(reordered_sigma(:,3),'EdgeColor','k','FaceColor','r')
% title('(B) \sigma^2 for Furosemide AUC_{0-t}','Color','black','FontSize',14)
% set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Fur,'FontSize',12);
% ax=gca;
% ax.YLabel.String='\sigma^2';
% ax.YLabel.FontSize=14;
% ax.XTickLabelRotation = 45;
% ax.YLabel.FontWeight='bold';
% ax.XLim = [0 58];
