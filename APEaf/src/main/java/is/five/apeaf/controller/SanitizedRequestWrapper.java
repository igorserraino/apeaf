package is.five.apeaf.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import is.five.apeaf.utils.SanUtil;

public class SanitizedRequestWrapper extends HttpServletRequestWrapper {

    public SanitizedRequestWrapper(HttpServletRequest request) {
        super(request);
    }

    @Override
    public String getParameter(String name) {
        String value = super.getParameter(name);
        return sanitize(value);
    }

    @Override
    public String[] getParameterValues(String name) {
        String[] values = super.getParameterValues(name);
        if (values == null) return null;

        for (int i = 0; i < values.length; i++) {
            values[i] = sanitize(values[i]);
        }
        return values;
    }

    private String sanitize(String input) {
        if (input == null) return null;
        return SanUtil.sanitize(input);
    }
}

