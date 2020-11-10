package com.lcs.exception;

public class SysException extends Exception{
    String message;

    @Override
    public String toString() {
        return "SysException{" +
                "message='" + message + '\'' +
                '}';
    }

    @Override
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public SysException(String message) {
        this.message = message;
    }

    public SysException(String message, String message1) {
        super(message);
        this.message = message1;
    }

    public SysException(String message, Throwable cause, String message1) {
        super(message, cause);
        this.message = message1;
    }

    public SysException(Throwable cause, String message) {
        super(cause);
        this.message = message;
    }

    public SysException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace, String message1) {
        super(message, cause, enableSuppression, writableStackTrace);
        this.message = message1;
    }
}
