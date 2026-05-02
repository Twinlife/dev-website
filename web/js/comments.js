/**
 * Comment support script.
 * Copyright (C) Twinlife SA.
 * Written by Stephane Carrez (Stephane.Carrez@gmail.com)
 * SPDX-License-Identifier: Apache-2.0
 */
var Comments = /** @class */ (function () {
    function Comments(formId) {
        this.formId = formId;
        // Retrieve input elements from the form
        var form = this.getForm();
        if (!form) {
            throw new Error("Form not found");
        }
        this.c1 = form.querySelector("#c1");
        this.c2 = form.querySelector("#c2");
        this.c3 = form.querySelector("#c3");
        this.c4 = form.querySelector("#c4");
        this.c5 = form.querySelector("#c5");
        this.c6 = form.querySelector("#c6");
        if (!this.c1 || !this.c2 || !this.c3 || !this.c4 || !this.c5 || !this.c6) {
            throw new Error("One or more input elements not found in the form");
        }
        // Set input attributes
        [this.c1, this.c2, this.c3, this.c4, this.c5, this.c6].forEach(function (input) {
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
    Comments.prototype.getForm = function () {
        return document.getElementById(this.formId);
    };
    Comments.prototype.getTextArea = function () {
        var form = this.getForm();
        if (!form)
            return null;
        var textarea = form.querySelector("textarea");
        return textarea;
    };
    Comments.prototype.getSubmitButton = function () {
        var form = this.getForm();
        if (!form)
            return null;
        var input = form.querySelector("input[type='submit']");
        return input;
    };
    Comments.prototype.setupSubmitButton = function () {
        var _this = this;
        var submitButton = this.getSubmitButton();
        if (submitButton) {
            submitButton.addEventListener("click", function (e) {
                e.preventDefault();
                _this.submitComment();
            });
        }
    };
    Comments.prototype.submitComment = function () {
        var _this = this;
        var form = this.getForm();
        if (!form)
            return;
        var code = this.c1.value + this.c2.value + this.c3.value + this.c4.value + this.c5.value + this.c6.value;
        var formData = new FormData(form);
        formData.append("code", code);
        formData.append("create", "1");
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/blogs/forms/comment-form.html", true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    _this.handleSuccess();
                }
                else if (xhr.status === 401) {
                    _this.handleInvalidCode();
                }
                else if (xhr.status === 404) {
                    _this.handleNotFound();
                }
            }
        };
        xhr.send(formData);
    };
    Comments.prototype.handleSuccess = function () {
        var dl = this.c1.closest("dl");
        if (dl) {
            dl.classList.remove("asf-error");
            var errorMsg = dl.querySelector("dd.asf-error-msg");
            if (errorMsg) {
                errorMsg.remove();
            }
        }
        var textArea = this.getTextArea();
        if (textArea && textArea.parentElement) {
            textArea.style.display = "none";
            var messageDiv = document.createElement("div");
            messageDiv.textContent = "The comment was added and is waiting to be approved.";
            textArea.parentElement.insertBefore(messageDiv, textArea.nextSibling);
        }
    };
    Comments.prototype.handleInvalidCode = function () {
        var dl = this.c1.closest("dl");
        if (dl) {
            dl.classList.add("asf-error");
            var dd = dl.querySelector("dd.asf-error-msg");
            if (!dd) {
                dd = document.createElement("dd");
                dd.classList.add("asf-error-msg");
                dl.appendChild(dd);
            }
            dd.textContent = "The mini-code is invalid";
        }
    };
    Comments.prototype.handleNotFound = function () {
        var form = this.getForm();
        if (form) {
            var errorDiv = document.createElement("div");
            errorDiv.textContent = "The post was not found";
            form.prepend(errorDiv);
        }
    };
    Comments.prototype.setupInputListener = function (current, next) {
        current.addEventListener("focus", function () {
            current.select();
        });
        current.addEventListener("input", function () {
            var value = current.value;
            if (value.length === 1) {
                var upperValue = value.toUpperCase();
                if (/^[0-9A-Z]$/.test(upperValue)) {
                    current.value = upperValue;
                    if (next) {
                        next.focus();
                    }
                }
                else {
                    current.value = "";
                }
            }
            else if (value.length > 1) {
                current.value = value.slice(-1).toUpperCase();
                if (next) {
                    next.focus();
                }
            }
        });
    };
    return Comments;
}());
