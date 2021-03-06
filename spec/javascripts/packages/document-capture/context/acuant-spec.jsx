import { useContext } from 'react';
import { renderHook } from '@testing-library/react-hooks';
import AcuantContext, {
  Provider as AcuantContextProvider,
} from '@18f/identity-document-capture/context/acuant';
import { render } from '../../../support/document-capture';

describe('document-capture/context/acuant', () => {
  afterEach(() => {
    delete window.AcuantJavascriptWebSdk;
    delete window.AcuantCamera;
  });

  it('provides default context value', () => {
    const { result } = renderHook(() => useContext(AcuantContext));

    expect(result.current).to.eql({
      isReady: false,
      isError: false,
      isCameraSupported: null,
      credentials: null,
      endpoint: null,
    });
  });

  it('appends script element', () => {
    render(<AcuantContextProvider sdkSrc="about:blank" />);

    const script = document.querySelector('script[src="about:blank"]');

    expect(script).to.be.ok();
  });

  it('provides context from provider crendentials', () => {
    const { result } = renderHook(() => useContext(AcuantContext), {
      wrapper: ({ children }) => (
        <AcuantContextProvider sdkSrc="about:blank" credentials="a" endpoint="b">
          {children}
        </AcuantContextProvider>
      ),
    });

    expect(result.current).to.eql({
      isReady: false,
      isError: false,
      isCameraSupported: null,
      credentials: 'a',
      endpoint: 'b',
    });
  });

  it('provides ready context when successfully loaded', () => {
    const { result } = renderHook(() => useContext(AcuantContext), {
      wrapper: ({ children }) => (
        <AcuantContextProvider sdkSrc="about:blank">{children}</AcuantContextProvider>
      ),
    });

    window.AcuantJavascriptWebSdk = {
      initialize: (_credentials, _endpoint, { onSuccess }) => onSuccess(),
    };
    window.AcuantCamera = { isCameraSupported: true };
    window.onAcuantSdkLoaded();

    expect(result.current).to.eql({
      isReady: true,
      isError: false,
      isCameraSupported: true,
      credentials: null,
      endpoint: null,
    });
  });

  it('has camera availability at time of ready', () => {
    const { result } = renderHook(() => useContext(AcuantContext), {
      wrapper: ({ children }) => (
        <AcuantContextProvider sdkSrc="about:blank">{children}</AcuantContextProvider>
      ),
    });

    window.AcuantJavascriptWebSdk = {
      initialize: (_credentials, _endpoint, { onSuccess }) => onSuccess(),
    };
    window.AcuantCamera = { isCameraSupported: true };
    window.onAcuantSdkLoaded();

    expect(result.current.isCameraSupported).to.be.true();
  });

  it('provides error context when failed to loaded', () => {
    const { result } = renderHook(() => useContext(AcuantContext), {
      wrapper: ({ children }) => (
        <AcuantContextProvider sdkSrc="about:blank">{children}</AcuantContextProvider>
      ),
    });

    window.AcuantJavascriptWebSdk = {
      initialize: (_credentials, _endpoint, { onFail }) => onFail(),
    };
    window.onAcuantSdkLoaded();

    expect(result.current).to.eql({
      isReady: false,
      isError: true,
      isCameraSupported: null,
      credentials: null,
      endpoint: null,
    });
  });

  it('cleans up after itself on unmount', () => {
    const { unmount } = render(<AcuantContextProvider sdkSrc="about:blank" />);

    unmount();

    const script = document.querySelector('script[src="about:blank"]');

    expect(script).not.to.be.ok();
    expect(window.AcuantJavascriptWebSdk).to.be.undefined();
  });
});
