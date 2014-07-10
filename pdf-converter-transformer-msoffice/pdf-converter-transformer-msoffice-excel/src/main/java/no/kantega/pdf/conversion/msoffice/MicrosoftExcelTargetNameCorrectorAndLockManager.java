package no.kantega.pdf.conversion.msoffice;

import org.slf4j.Logger;
import org.zeroturnaround.exec.ProcessExecutor;

import java.io.File;
import java.util.concurrent.Semaphore;

public class MicrosoftExcelTargetNameCorrectorAndLockManager extends MicrosoftOfficeTargetNameCorrector {

    private final Semaphore conversionLock;
    private final Logger logger;

    public MicrosoftExcelTargetNameCorrectorAndLockManager(File target, String fileExtension, Semaphore conversionLock, Logger logger) {
        super(target, fileExtension);
        this.conversionLock = conversionLock;
        this.logger = logger;
    }

    @Override
    public void beforeStart(ProcessExecutor executor) {
        logger.trace("Attempting to acquire MS Excel conversion lock");
        conversionLock.acquireUninterruptibly();
        logger.trace("Acquired MS Excel conversion lock");
        super.beforeStart(executor);
    }

    @Override
    public void afterStop(Process process) {
        conversionLock.release();
        logger.trace("Released MS Excel conversion lock");
        super.afterStop(process);
    }

    @Override
    protected boolean targetHasNoFileExtension() {
        return !fileExtension.equals("txt") && super.targetHasNoFileExtension();
    }

    @Override
    protected boolean targetHasWrongFileExtensionForPdf() {
        return fileExtension.equals("pdf") && super.targetHasWrongFileExtensionForPdf();
    }
}
