import { LightningElement } from 'lwc';
import generatePayload from '@salesforce/apex/AccountUpdatePayloadController.generatePayload';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountPayloadPreview extends LightningElement {
    accountId;
    payload;
    errorMessage;
    isLoading = false;
    pastedPayload = '';

    handlePastedPayloadChange(event) {
        this.pastedPayload = event.target.value;
    }

    get isGenerateDisabled() {
        return !this.accountId || this.isLoading;
    }

    handleAccountChange(event) {
        this.accountId = event.detail.recordId;
        this.payload = null;
        this.errorMessage = null;
        this.pastedPayload = '';
    }

    async handleGeneratePayload() {
        this.payload = null;
        this.errorMessage = null;
        this.isLoading = true;

        try {
            const response = await generatePayload({
                accountId: this.accountId
            });

            if (response.success) {
                this.payload = response.payload;
            } else {
                this.errorMessage = response.errorMessage;
            }
        } catch (error) {
            this.errorMessage = this.reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleCopyPayload() {
        try {
            await navigator.clipboard.writeText(this.payload);

            this.showToast(
                'Payload copied',
                'The generated JSON payload was copied to your clipboard.',
                'success'
            );
        } catch (error) {
            this.showToast(
                'Copy failed',
                'Copy the payload manually from the preview box.',
                'error'
            );
        }
    }

    handleClear() {
        this.accountId = null;
        this.payload = null;
        this.errorMessage = null;
        this.pastedPayload = '';
    }

    reduceError(error) {
        if (Array.isArray(error?.body)) {
            return error.body.map((entry) => entry.message).join(', ');
        }

        if (typeof error?.body?.message === 'string') {
            return error.body.message;
        }

        if (typeof error?.message === 'string') {
            return error.message;
        }

        return 'Unexpected error while generating the payload.';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}