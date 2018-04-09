%% Generate figures for APAP

Labels_APAP={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejum 1 Porosity/Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Length',' Caecum TT',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Length', 'Colon TT',...
            'FFV SI', 'FFV Colon','SI Length','SI Radius','SI TT',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','[Blood/Plasma] Ratio', 'Plasma Fup','Volume of Distribution','k12','k21',...
            'Systemic Clearance','Renal Clearance'};
 
reordered_mu_star=vertcat(func_mu_star_SigFig(1:39,:),func_mu_star_SigFig(41:43,:),func_mu_star_SigFig(51:54,:),func_mu_star_SigFig(40,:),func_mu_star_SigFig(44:46,:),func_mu_star_SigFig(48:50,:),func_mu_star_SigFig(47,:),func_mu_star_SigFig(55,:));
reordered_mu=vertcat(func_mu_SigFig(1:39,:),func_mu_SigFig(41:43,:),func_mu_SigFig(51:54,:),func_mu_SigFig(40,:),func_mu_SigFig(44:46,:),func_mu_SigFig(48:50,:),func_mu_SigFig(47,:),func_mu_SigFig(55,:));
reordered_sigma=vertcat(func_sigma_SigFig(1:39,:),func_sigma_SigFig(41:43,:),func_sigma_SigFig(51:54,:),func_sigma_SigFig(40,:),func_sigma_SigFig(44:46,:),func_sigma_SigFig(48:50,:),func_sigma_SigFig(47,:),func_sigma_SigFig(55,:));
  
figure
% subplot(2,1,1)
barh(reordered_mu_star(:,1),'EdgeColor','k','FaceColor','g')
hold on
hline=refline([0 Cutoff_Mu_Star_Cmax]);
hline.Color='red';
hline.LineStyle='--';
title('(A) Acetaminophen C_{max}','Color','black','FontSize',14)
set(gca, 'YTick', 1:55, 'YTickLabel', Labels_APAP,'FontSize',12);
ax=gca;
ax.XLabel.String='\mu*';
ax.XLabel.FontWeight='bold';
ax.XLabel.FontSize=14;
ax.YLim = [0 56];
%ax.YLim = [0 20];
hold off

figure
% subplot(2,1,2)
barh(reordered_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on 
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(B) Acetaminophen t_{max}','Color','black','FontSize',12)
set(gca, 'YTick', 1:55, 'YTickLabel', Labels_APAP,'FontSize',10);
ax=gca;
ax.XLabel.String='\mu*';
ax.XLabel.FontSize=12;
ax.XLabel.FontWeight='bold';
ax.YLim = [0 56];
%ax.YLim = [0 4];
hold off
 
figure
% subplot(2,1,1)
barh(reordered_mu_star(:,3),'EdgeColor','k','FaceColor','r')
hold on
hline=refline(0,Cutoff_Mu_Star_AUC)
hline.Color='red';
hline.LineStyle='--';
title('(C) Acetaminophen AUC_{0-t}','Color','black','FontSize',14)
set(gca, 'YTick', 1:55, 'YTickLabel', Labels_APAP,'FontSize',12);
ax=gca;
ax.XLabel.String='\mu*';
ax.XLabel.FontWeight='bold';
ax.XLabel.FontSize=14;
ax.YLim = [0 56];
hold off


%% Generate figures for Risperidone

Labels_Risp={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejum 1 Porosity/Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Length',' Caecum TT',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Length', 'Colon TT',...
            'FFV SI', 'FFV Colon','SI Length','SI Radius','SI TT',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','[Blood/Plasma] Ratio', 'Plasma Fup','Volume of Distribution','k12','k21','k13','k31',...
            'Systemic Clearance','FPE Liver'};
 
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
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];
%ax.YLim = [0 20];
hold off
 
subplot(2,1,2)
bar(reordered_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on 
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(B) Risperidone t_{max}','Color','black','FontSize',14)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels_Risp,'FontSize',12);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontSize=14;
ax.XTickLabelRotation = 45;
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
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];
hold off


%% Generate figures for Atenolol

Labels_Aten={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejum 1 Porosity/Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Length',' Caecum TT',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Length', 'Colon TT',...
            'FFV SI', 'FFV Colon','SI Length','SI Radius','SI TT',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','[Blood/Plasma] Ratio', 'Plasma Fup','Volume of Distribution','k12','k21',...
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
ax.XTickLabelRotation = 45;
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
ax.XTickLabelRotation = 45;
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
ax.XTickLabelRotation = 45;
ax.XLim = [0 55];
hold off


%% Generate figures for Furosemide

Labels_Fur={'Gastric pH','Gastric Volume','Gastric Pore Radius','Gastric Porosity/Length','Gastric Emptying Time',...
            'Duodenum pH','Duodenum Bile Salt','Duodenum Pore Radius','Duodenum Porosity/Length',...
            'Jejunum 1 pH','Jejunum 1 Bile Salt','Jejunum 1 Pore Radius','Jejum 1 Porosity/Length',...
            'Jejunum 2 Bile Salt','Jejunum 2 Pore Radius','Jejunum 2 Porosity/Length',...
            'Ileum 1 Bile Salt','Ileum 1 Pore Radius','Ileum 1 Porosity/Length',...
            'Ileum 2 Bile Salt','Ileum 2 Pore Radius','Ileum 2 Porosity/Length',...
            'Ileum 3 Bile Salt','Ileum 3 Pore Radius','Ileum 3 Porosity/Length',...
            'Caecum pH', 'Caecum Length', 'Caecum Radius','Caecum Pore Radius','Caecum Porosity/Length',' Caecum TT',...
            'Colon pH', 'Colon Length', 'Colon Radius','Colon Pore Radius','Colon Porosity/Length', 'Colon TT',...
            'FFV SI', 'FFV Colon','SI Length','SI Radius','SI TT',...
            'ASF C1', 'ASF C2', 'ASF C3', 'ASF C4',...
            'Hepatic Blood Flow','Body Weight','[Blood/Plasma] Ratio', 'Plasma Fup','Volume of Distribution','k12','k21','k13','k31',...
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
ax.XTickLabelRotation = 45;
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
ax.XTickLabelRotation = 45;
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
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];
hold off