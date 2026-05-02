class Comments {
    readonly c1: HTMLInputElement;
    readonly c2: HTMLInputElement;
    readonly c3: HTMLInputElement;
    readonly c4: HTMLInputElement;
    readonly c5: HTMLInputElement;
    readonly c6: HTMLInputElement;
    private formId: string;

    constructor(formId: string) {
        this.formId = formId;

        // Retrieve input elements from the form
        const form = this.getForm();
        if (!form) {
            throw new Error("Form not found");
        }

        this.c1 = form.querySelector("#c1") as HTMLInputElement;
        this.c2 = form.querySelector("#c2") as HTMLInputElement;
        this.c3 = form.querySelector("#c3") as HTMLInputElement;
        this.c4 = form.querySelector("#c4") as HTMLInputElement;
        this.c5 = form.querySelector("#c5") as HTMLInputElement;
        this.c6 = form.querySelector("#c6") as HTMLInputElement;

        if (!this.c1 || !this.c2 || !this.c3 || !this.c4 || !this.c5 || !this.c6) {
            throw new Error("One or more input elements not found in the form");
        }

        // Set input attributes
        [this.c1, this.c2, this.c3, this.c4, this.c5, this.c6].forEach(input => {
            input.maxLength = 1;
            input.style.textTransform = "uppercase";
        });

        // Add event listeners for input handling
        this.setupInputListener(this.c1, this.c2);
        this.setupInputListener(this.c2, this.c3);
        this.setupInputListener(this.c3, this.c4);
        this.setupInputListener(this.c4, this.c5);
        this.setupInputListener(this.c5, this.c6);
        this.setupInputListener(this.c6, this.getTextArea());

        // Add event listener for submit button
        this.setupSubmitButton();
    }

    private getForm(): HTMLFormElement | null {
        return document.getElementById(this.formId) as HTMLFormElement | null;
    }

    private getTextArea(): HTMLTextAreaElement | null {
        const form = this.getForm();
        if (!form) return null;
        const textarea = form.querySelector("textarea");
        return textarea as HTMLTextAreaElement | null;
    }

    private getSubmitButton(): HTMLInputElement | null {
        const form = this.getForm();
        if (!form) return null;
        const input = form.querySelector("input[type='submit']");
        return input as HTMLInputElement | null;
    }

    private setupSubmitButton(): void {
        const submitButton = this.getSubmitButton();
        if (submitButton) {
            submitButton.addEventListener("click", (e) => {
                e.preventDefault();
                this.submitComment();
            });
        }
    }

    private submitComment(): void {
        const form = this.getForm();
        if (!form) return;

        const code = this.c1.value + this.c2.value + this.c3.value + this.c4.value + this.c5.value + this.c6.value;
        const formData = new FormData(form);
        formData.append("code", code);
        formData.append("create", "1");

        const xhr = new XMLHttpRequest();
        xhr.open("POST", "/blogs/forms/comment-form.html", true);
        xhr.onreadystatechange = () => {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    this.handleSuccess();
                } else if (xhr.status === 401) {
                    this.handleInvalidCode();
                } else if (xhr.status === 404) {
                    this.handleNotFound();
                }
            }
        };
        xhr.send(formData);
    }

    private handleSuccess(): void {
        const dl = this.c1.closest("dl");
        if (dl) {
            dl.classList.remove("asf-error");
            const errorMsg = dl.querySelector("dd.asf-error-msg");
            if (errorMsg) {
                errorMsg.remove();
            }
        }

        const textArea = this.getTextArea();
        if (textArea && textArea.parentElement) {
            textArea.style.display = "none";
            const messageDiv = document.createElement("div");
            messageDiv.textContent = "The comment was added and is waiting to be approved.";
            textArea.parentElement.insertBefore(messageDiv, textArea.nextSibling);
        }
    }

    private handleInvalidCode(): void {
        const dl = this.c1.closest("dl");
        if (dl) {
            dl.classList.add("asf-error");
            let dd = dl.querySelector("dd.asf-error-msg");
            if (!dd) {
                dd = document.createElement("dd");
                dd.classList.add("asf-error-msg");
                dl.appendChild(dd);
            }
            dd.textContent = "The mini-code is invalid";
        }
    }

    private handleNotFound(): void {
        const form = this.getForm();
        if (form) {
            const errorDiv = document.createElement("div");
            errorDiv.textContent = "The post was not found";
            form.prepend(errorDiv);
        }
    }

    private setupInputListener(current: HTMLInputElement, next: HTMLInputElement | HTMLTextAreaElement | null): void {
        current.addEventListener("focus", () => {
            current.select();
        });
        current.addEventListener("input", () => {
            const value = current.value;
            if (value.length === 1) {
                const upperValue = value.toUpperCase();
                if (/^[0-9A-Z]$/.test(upperValue)) {
                    current.value = upperValue;
                    if (next) {
                        next.focus();
                    }
                } else {
                    current.value = "";
                }
            } else if (value.length > 1) {
                current.value = value.slice(-1).toUpperCase();
                if (next) {
                    next.focus();
                }
            }
        });
    }
}
