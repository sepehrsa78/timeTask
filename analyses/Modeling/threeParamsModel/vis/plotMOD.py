import seaborn as sns
import numpy as np

def plotModelOverData(axs, axr, axc, timeInts, muData, siData, muModel, siModel, type, unit, xLim, yLim, colData, colModel, modType, AIC):
    
    sns.lineplot(x=np.linspace(xLim[0], xLim[1], xLim[1]), y=np.linspace(yLim[0], yLim[1], yLim[1]), linestyle="dashed", color='black', ax=axs[axr][axc])
    eb1=axs[axr][axc].errorbar(timeInts, muData, yerr=siData, fmt='o', color=colData, label='Mean with SD')
    eb2=axs[axr][axc].errorbar(timeInts, muModel, yerr=siModel, fmt='o', color=colModel, label='Mean with SD')
    eb2[-1][0].set_linestyle('dotted')
    axs[axr][axc].set_xlabel(f'{type} Interval ({unit})')
    axs[axr][axc].set_ylabel(f'Reproduced {type} ({unit})')
    axs[axr][axc].set_title(f'AIC Value: {AIC}')
    axs[axr][axc].set_xticks(timeInts)
    axs[axr][axc].set_xlim(xLim)
    axs[axr][axc].set_ylim(yLim)
    axs[axr][axc].legend([eb1, eb2], ['Data', f'Model: {modType}'])