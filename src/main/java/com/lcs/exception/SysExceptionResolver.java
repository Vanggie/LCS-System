package com.lcs.exception;

import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SysExceptionResolver implements HandlerExceptionResolver {

    @Override
    public ModelAndView resolveException(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object handler, Exception e) {
        //
        SysException ex = null;
        if(e instanceof SysException){
            ex = (SysException)e;
        }
        else{
            ex = new SysException("System under maintenance");
        }

        ModelAndView mv = new ModelAndView();
        mv.addObject("errorMessage", ex.getMessage());
        mv.setViewName("error");
        return mv;
    }
}
