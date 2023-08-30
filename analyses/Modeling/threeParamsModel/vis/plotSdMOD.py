import seaborn as sns
import numpy as np

def plotSdModelOverData(axs, axn, Ints, siData, siModel, type, unit, xLim, yLim, colData, colModel):
    
    sns.lineplot(x=np.linspace(xLim[0], xLim[1], xLim[1]), y=np.linspace(yLim[0], yLim[1], yLim[1]), linestyle="dashed", color='black', ax=axs[axn])
    dat=axs[axn].scatter(x=Ints, y=siData, color=colData)
    mod=axs[axn].scatter(x=Ints, y=siModel, color=colModel)
    axs[axn].set_xlabel(f'{type} Interval ({unit})')
    axs[axn].set_ylabel(f'SD ({unit})')
    axs[axn].set_title(f'Reproduced {type} SD')
    axs[axn].set_xticks(Ints)
    axs[axn].set_xlim(xLim)
    axs[axn].set_ylim(yLim)
    axs[axn].legend([dat, mod], ['Data', 'Model'])


