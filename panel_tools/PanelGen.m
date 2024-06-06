function [AC,PanelDat,FC,AcSurf]=PanelGen(input_filename)
[AC,FC]=feval(input_filename);
nSurf=size(AC,2);

PanelDat.Nodes=[];
PanelDat.NodesW=[];
PanelDat.VtxPt=[];
PanelDat.Ring2Lift=[];
PanelDat.ColPt=[];
PanelDat.NormV=[];
PanelDat.delx=[];
PanelDat.dely=[];
PanelDat.S=[];
PanelDat.WingPanel=[];
PanelDat.WakePanel=[];
PanelDat.TrailPanel=[];
PanelDat.SurfID=[];
nnode=[];nwake=[];npanel=[];
surfNum1=0;
iSurf=0;
for i=1:nSurf
    iLabel1=strcmp({AC(i).Label}, 'Wing');%Wing
    iLabel2=strcmp({AC(i).Label}, 'Horizontal tail');%Horizontal tail
    iLabel3=strcmp({AC(i).Label}, 'Vertical tail');%Vertical tail
    iLabel4=strcmp({AC(i).Label}, 'Fuselage');%Fuselage
    if iLabel1||iLabel2||iLabel3||iLabel4
        %% Natee fix error for input without SubSurf (no control surfaces)
        if ~isfield(AC(i),'SubSurf')
            AC(i).SubSurf=[];
        end
        %%
        if size(AC(i).SubSurf,2)==0
            iSurf=iSurf+1;
            AcSurf=fullWingPanelGen(AC(i),[0 1]);
            panelDat=MappedMeshAeroNew(AC(i),AcSurf,2);%second mode panel index see details in MappedMeshAeroNew.m

            nvtx(iSurf)=size(panelDat.VtxPt,1);
            nnode(iSurf)=size(panelDat.Nodes,1);
            npanel(iSurf)=size(panelDat.WingPanel,1);
            nwake(iSurf)=size(panelDat.NodesW,1);
            
            %Natee - Store Name of Subsurfs and their panel index
            PanelDat.SurfName{iSurf}=AC(i).Label;
            NP1=size(PanelDat.WingPanel,1);
            NP2=size(panelDat.WingPanel,1);
            PanelDat.SurfID{iSurf}=(NP1+1):(NP1+NP2);
            %

            PanelDat.Nodes=[PanelDat.Nodes;panelDat.Nodes];
            PanelDat.NodesW=[PanelDat.NodesW;panelDat.NodesW];
            PanelDat.VtxPt=[PanelDat.VtxPt;panelDat.VtxPt];
            PanelDat.Ring2Lift=[PanelDat.Ring2Lift zeros(sum(npanel(1:iSurf-1)),npanel(iSurf));zeros(npanel(iSurf),sum(npanel(1:iSurf-1))) panelDat.Ring2Lift];
            PanelDat.ColPt=[PanelDat.ColPt;panelDat.ColPt];
            PanelDat.NormV=[PanelDat.NormV;panelDat.NormV];
            PanelDat.delx=[PanelDat.delx;panelDat.delx];
            PanelDat.dely=[PanelDat.dely;panelDat.dely];
            PanelDat.S=[PanelDat.S;panelDat.S];
            PanelDat.WingPanel=[PanelDat.WingPanel;panelDat.WingPanel+sum(nnode(1:iSurf-1))];
            PanelDat.WakePanel=[PanelDat.WakePanel;panelDat.WakePanel+sum(nwake(1:iSurf-1))];
            PanelDat.TrailPanel=[PanelDat.TrailPanel;panelDat.TrailPanel+sum(npanel(1:iSurf-1))];
        elseif size(AC(i).SubSurf,2)>0
            [iInterval,iSubSurf]=getWingSec(AC(i));
            for j=1:length(iSubSurf)
                iSurf=iSurf+1;
                if iSubSurf(j)==0
                    AcSurf=fullWingPanelGen(AC(i),[iInterval(j) iInterval(j+1)]);
                else
                    AcSurf=splitWingPanelGen(AC(i),iSubSurf(j));
                    iPanel=sum(npanel(1:iSurf-1));
                    AC(i).SubSurf(iSubSurf(j)).RpanelNum=iPanel+...
                            AcSurf.RpanelNum;
                    AC(i).SubSurf(iSubSurf(j)).HingePt_R=AcSurf.HingePt_R;
                    AC(i).SubSurf(iSubSurf(j)).RotAxis_R=AcSurf.RotAxis_R;
                    if strcmp(AC(i).Symmetry,'yes')
                        AC(i).SubSurf(iSubSurf(j)).LpanelNum=iPanel+...
                            AcSurf.LpanelNum;
                        AC(i).SubSurf(iSubSurf(j)).HingePt_L=AcSurf.HingePt_L;
                        AC(i).SubSurf(iSubSurf(j)).RotAxis_L=AcSurf.RotAxis_L;
                    end
                end
                
                panelDat=MappedMeshAeroNew(AC(i),AcSurf,2);%second mode panel index see details in MappedMeshAeroNew.m

                nvtx(iSurf)=size(panelDat.VtxPt,1);
                nnode(iSurf)=size(panelDat.Nodes,1);
                npanel(iSurf)=size(panelDat.WingPanel,1);
                nwake(iSurf)=size(panelDat.NodesW,1);
                
                %Natee - Store Name of Subsurfs and their panel index
                if iSubSurf(j)==0
                    PanelDat.SurfName{iSurf}=AC(i).Label;
                else
                    PanelDat.SurfName{iSurf}=AC(i).SubSurf(iSubSurf(j)).Name;
                end
                NP1=size(PanelDat.WingPanel,1);
                NP2=size(panelDat.WingPanel,1);
                PanelDat.SurfID{iSurf}=(NP1+1):(NP1+NP2);
                %

                PanelDat.Nodes=[PanelDat.Nodes;panelDat.Nodes];
                PanelDat.NodesW=[PanelDat.NodesW;panelDat.NodesW];
                PanelDat.VtxPt=[PanelDat.VtxPt;panelDat.VtxPt];
                PanelDat.Ring2Lift=[PanelDat.Ring2Lift zeros(sum(npanel(1:iSurf-1)),npanel(iSurf));zeros(npanel(iSurf),sum(npanel(1:iSurf-1))) panelDat.Ring2Lift];
                PanelDat.ColPt=[PanelDat.ColPt;panelDat.ColPt];
                PanelDat.NormV=[PanelDat.NormV;panelDat.NormV];
                PanelDat.delx=[PanelDat.delx;panelDat.delx];
                PanelDat.dely=[PanelDat.dely;panelDat.dely];
                PanelDat.S=[PanelDat.S;panelDat.S];
                PanelDat.WingPanel=[PanelDat.WingPanel;panelDat.WingPanel+sum(nnode(1:iSurf-1))];
                PanelDat.WakePanel=[PanelDat.WakePanel;panelDat.WakePanel+sum(nwake(1:iSurf-1))];
                PanelDat.TrailPanel=[PanelDat.TrailPanel;panelDat.TrailPanel+sum(npanel(1:iSurf-1))];
            end
        end

    end
end
PanelDat.nvtx=nvtx;
PanelDat.nnode=nnode;
PanelDat.npanel=npanel;
PanelDat.nwake=nwake;


Trl=PanelDat.Ring2Lift;
nPanel=size(PanelDat.WingPanel,1);
% save PanelTemp Trl nPanel

% AC(1).SubSurf(1).RpanelNum
% AC(1).SubSurf(1).LpanelNum
% AC(1).SubSurf(2).RpanelNum
% AC(1).SubSurf(2).LpanelNum
% 
% AC(2).SubSurf(1).RpanelNum
% AC(2).SubSurf(1).LpanelNum
% 
% AC(3).SubSurf(1).RpanelNum


% plotPanel(PanelDat.Nodes,PanelDat.WingPanel,'fill','g','off','on')
% plotPanel(PanelDat.NodesW,PanelDat.WakePanel,'fill','c','off','on')
% Colors=['g' 'm' 'g' 'r' 'g' 'r' 'b' 'r'];
% plotColoredSurfs(PanelDat.Nodes,PanelDat.WingPanel,...
%     PanelDat.SurfID,Colors,'fill','off','off')
% view(30,70)
% axis equal

%%%%%%%%% sub-functions %%%%%%%
function [iInterval,iSubSurf]=getWingSec(AC)
iInterval=[0 1];
for i=1:size(AC.SubSurf,2)
    iInterval=[iInterval AC.SubSurf(i).SpanData(1:2)];
end
iInterval=sort(unique(iInterval));
for i=1:(length(iInterval)-1)
    iSubSurf(i)=0;% no flap
    for j=1:size(AC.SubSurf,2)
        if AC.SubSurf(j).SpanData(1)==iInterval(i)&AC.SubSurf(j).SpanData(2)==iInterval(i+1)
            iSubSurf(i)=j;
            break
        end
    end
end
%%%%%%%%%% End of file %%%%%%%%%%
    