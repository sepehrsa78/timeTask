def plotBiasVersusVariance(axs, axn, biasModel, varModel, biasData, varData, xLim, yLim, label, modCol, datCol):
    axs[axn].scatter(biasModel, varModel, color=modCol, label='Model')
    axs[axn].scatter(biasData, varData, color=datCol, label='Data')
    axs[axn].set_xlim(xLim)
    axs[axn].set_ylim(yLim)
    axs[axn].set_xlabel('Bias')
    axs[axn].set_ylabel('Variance')
    axs[axn].set_title(f'Bias vs. Variance for {label}')
    axs[axn].legend()