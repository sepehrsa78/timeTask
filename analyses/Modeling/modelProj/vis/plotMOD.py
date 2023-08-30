import seaborn as sns
import numpy as np

def plotModelOverData(axs, axn, timeInts, muData, siData, muModel, siModel, type, unit, xLim, yLim, colData, colModel):
    
    sns.lineplot(x=np.linspace(xLim[0], xLim[1], xLim[1]), y=np.linspace(yLim[0], yLim[1], yLim[1]), linestyle="dashed", color='black', ax=axs[axn])
    eb1=axs[axn].errorbar(timeInts, muData, yerr=siData, fmt='o', color=colData, label='Mean with SD')
    eb2=axs[axn].errorbar(timeInts, muModel, yerr=siModel, fmt='o', color=colModel, label='Mean with SD')
    eb2[-1][0].set_linestyle('dotted')
    axs[axn].set_xlabel(f'{type} Interval ({unit})')
    axs[axn].set_ylabel(f'Reproduced {type} ({unit})')
    axs[axn].set_title(f'Mean Reproduced {type} ± (SD)')
    axs[axn].set_xticks(timeInts)
    axs[axn].set_xlim(xLim)
    axs[axn].set_ylim(yLim)
    axs[axn].legend([eb1, eb2], ['Data', 'Model'])