//
//  ViewController.swift
//  gradients
//
//  Created by tambi on 9/11/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    function HSLtoRGB(s, M, t) {
      let e, w, L;
      const D = s => Math.floor(Math.max(Math.min(256 * s, 255), 0)),
        i = (s, M, t) => (
          t < 0 && (t += 1),
          t > 1 && (t -= 1),
          t < 1 / 6
            ? s + 6 * (M - s) * t
            : t < 0.5
            ? M
            : t < 2 / 3
            ? s + (M - s) * (2 / 3 - t) * 6
            : s
        ),
        r = t < 0.5 ? t * (1 + M) : t + M - t * M,
        N = 2 * t - r;
      return (
        (e = i(N, r, s + 1 / 3)),
        (w = i(N, r, s)),
        (L = i(N, r, s - 1 / 3)),
        [D(e), D(w), D(L)]
      );
    }
    function RGBtoHex(s, M, t) {
      return `#${s.toString(16)}${M.toString(16)}${t.toString(16)}`;
    }
    const randomColor = () => {
      const s = Math.random(),
        M =
          (Math.floor(360 * s),
          HSLtoRGB(s, 1, 0.01 * (Math.floor(16 * Math.random()) + 75)));
      return RGBtoHex(M[0], M[1], M[2]);
    };
    function getRelativeMousePosition(s, M) {
      var t = (M = M || s.target).getBoundingClientRect();
      return { x: s.clientX - t.left, y: s.clientY - t.top };
    }
    function getNoPaddingNoBorderCanvasRelativeMousePosition(s, M) {
      var t = getRelativeMousePosition(s, (M = M || s.target));
      return (
        (t.x = (t.x * M.width) / M.clientWidth),
        (t.y = (t.y * M.height) / M.clientHeight),
        t
      );
    }
    let image,
      warps,
      src_c,
      dst_c,
      texture,
      MAX_POINTS = 32,
      colors = {
        tl: randomColor(),
        tr: randomColor(),
        bl: randomColor(),
        br: randomColor()
      };
    function load_resource(s) {
      let M = new XMLHttpRequest();
      return (
        M.open("GET", s, !1),
        M.overrideMimeType("text/plain; charset=x-user-defined"),
        M.send(null),
        200 != M.status && 0 != M.status ? null : M.responseText
      );
    }
    function load_source(s) {
      let M = document.getElementById(s);
      if (!M) throw Error("element '" + s + "' not found");
      return M.hasAttribute("src") ? load_resource(M.src) : M.text;
    }
    function Warp(s, M, t, e) {
      (this.parent = s),
        (this.which = M),
        (this.src = t),
        (this.dst = e),
        (this.s2 = []),
        (this.w = []);
      for (let s = 0; s < MAX_POINTS; s++) this.s2.push(0), this.w.push([0, 0]);
    }
    function linsolve(s, M) {
      let t = s.length,
        e = s[0].length,
        w = M[0].length;
      for (let L = 0; L < e - 1; L++) {
        let D = L,
          i = D + 1,
          r = Math.abs(s[D][L]),
          N = D;
        for (let M = D + 1; M < t; M++) {
          let t = Math.abs(s[M][L]);
          r < t && ((r = t), (N = M));
        }
        if (N != D) {
          let t = s[D];
          (s[D] = s[N]), (s[N] = t);
          let e = M[D];
          (M[D] = M[N]), (M[N] = e);
        }
        for (let r = i; r < t; r++) {
          let t = s[D][L],
            i = s[r][L];
          for (let M = L; M < e; M++) s[r][M] = t * s[r][M] - i * s[D][M];
          for (let s = 0; s < w; s++) M[r][s] = t * M[r][s] - i * M[D][s];
        }
      }
      for (let e = t - 1; e >= 0; e--) {
        for (let L = t - 1; L > e; L--) {
          let t = s[e][L];
          s[e][L] = 0;
          for (let s = 0; s < w; s++) M[e][s] -= t * M[L][s];
        }
        for (let t = 0; t < w; t++) M[e][t] /= s[e][e];
        s[e][e] = 1;
      }
      return M;
    }
    function Warps(s = [], M = [], t = 0) {
      (this.npoints = t), (this.src = s), (this.dst = M);
      for (let s = t; s < MAX_POINTS; s++)
        this.src.push([0, 0]), this.dst.push([0, 0]);
      this.src.map(s =>
        "number" != typeof s[0] || "number" != typeof s[1] ? [0, 0] : s
      ),
        this.dst.map(s =>
          "number" != typeof s[0] || "number" != typeof s[1] ? [0, 0] : s
        ),
        (this.warps = [
          new Warp(this, 0, this.src, this.dst),
          new Warp(this, 1, this.dst, this.src)
        ]);
    }
    function Canvas(s, M, t, e) {
      (this.warp = s),
        (this.id = t),
        (this.canvas = M),
        M.setAttribute("tabIndex", s.which + 1),
        (this.ctx = M.getContext("webgl", { preserveDrawingBuffer: !0 })),
        (this.isClone = e),
        (this.errors = null),
        (this.texture = null),
        (this.position_buffer = null),
        (this.texcoord_buffer = null),
        (this.index_buffer = null),
        (this.num_indices = null),
        (this.warp_program = null),
        (this.drag = null),
        (this.radius = 10),
        this.setup();
    }
    function flatten(s, M) {
      if (!M) return s;
      let t = [];
      for (let e = 0; e < s.length; e++) {
        let w = s[e];
        M > 1 && (w = flatten(w, M - 1));
        for (let s = 0; s < w.length; s++) t.push(w[s]);
      }
      return t;
    }
    function refresh() {
      (colors.tl = randomColor()),
        (colors.tr = randomColor()),
        (colors.bl = randomColor()),
        (colors.br = randomColor()),
        updateColors(),
        updateUrl(),
        redraw();
    }
    function clearUrl() {
      window.history.replaceState({}, "/", (location.hostname, "/")), init();
    }
    (Warp.prototype = new Object()),
      (Warp.prototype.npoints = function() {
        return this.parent.npoints;
      }),
      (Warp.prototype.get_src = function() {
        let s = this.src.slice(0, this.npoints());
        for (let M = 0; M < s.length; M++) s[M] = s[M].slice();
        return s;
      }),
      (Warp.prototype.get_dst = function() {
        let s = this.dst.slice(0, this.npoints());
        for (let M = 0; M < s.length; M++) s[M] = s[M].slice();
        return s;
      }),
      (Warp.prototype.distance_squared = function(s, M, t) {
        if (t) {
          let M = [];
          for (let t = 0; t < s.length; t++) {
            let e = [];
            for (let M = 0; M < s.length; M++)
              e.push(s[t][0] * s[M][0] + s[t][1] * s[M][1]);
            M.push(e);
          }
          let t = [];
          for (let e = 0; e < s.length; e++) {
            let w = [];
            for (let t = 0; t < s.length; t++)
              w.push(M[e][e] + M[t][t] - 2 * M[e][t]);
            t.push(w);
          }
          return t;
        }
        {
          let t = [];
          for (let e = 0; e < s.length; e++) {
            let w = [];
            for (let t = 0; t < M.length; t++)
              w.push(s[e][0] * M[t][0] + s[e][1] * M[t][1]);
            t.push(w);
          }
          let e = [];
          for (let M = 0; M < s.length; M++)
            e.push(s[M][0] * s[M][0] + s[M][1] * s[M][1]);
          let w = [];
          for (let s = 0; s < M.length; s++)
            w.push(M[s][0] * M[s][0] + M[s][1] * M[s][1]);
          let L = [];
          for (let D = 0; D < s.length; D++) {
            let s = [];
            for (let L = 0; L < M.length; L++) s.push(e[D] + w[L] - 2 * t[D][L]);
            L.push(s);
          }
          return L;
        }
      }),
      (Warp.prototype.rbf = function(s, M, t) {
        let e = this.distance_squared(s, M, t);
        if (t) {
          let s = e[0][0];
          for (let M = 0; M < e.length; M++)
            for (let t = 0; t < e[M].length; t++) s < e[M][t] && (s = e[M][t]);
          let M = [];
          for (let t = 0; t < e.length; t++) {
            let w = [];
            for (let M = 0; M < e[t].length; M++) w.push(t == M ? s : e[t][M]);
            M.push(w);
          }
          for (let s = 0; s < M[0].length; s++) {
            let t = M[0][s];
            for (let e = 1; e < M.length; e++) t > M[e][s] && (t = M[e][s]);
            this.s2[s] = t;
          }
        }
        let w = [];
        for (let s = 0; s < e.length; s++) {
          let M = [];
          for (let t = 0; t < e[s].length; t++)
            M.push(Math.sqrt(e[s][t] + this.s2[t]));
          w.push(M);
        }
        return w;
      }),
      (Warp.prototype.update = function() {
        if (this.npoints() < 4) return;
        let s = this.get_src(),
          M = this.get_dst(),
          t = linsolve(this.rbf(s, s, !0), M);
        for (let s = 0; s < t.length; s++) this.w[s] = t[s];
      }),
      (Warp.prototype.warp = function(s) {
        if (this.npoints() < 4) return s.slice();
        let M = this.rbf(s, this.get_src()),
          t = [];
        for (let s = 0; s < M.length; s++) {
          let e = [];
          for (let t = 0; t < 2; t++) {
            let w = 0;
            for (let e = 0; e < M[s].length; e++) w += M[s][e] * this.w[e][t];
            e.push(w);
          }
          t.push(e);
        }
        return t;
      }),
      (Warps.prototype = new Object()),
      (Warps.prototype.update = function() {
        for (let s = 0; s < this.warps.length; s++) this.warps[s].update();
      }),
      (Warps.prototype.add = function(s, M, t, e, w) {
        if (w) {
          let w = s;
          (s = t), (t = w);
          let L = M;
          (M = e), (e = L);
        }
        (this.src[this.npoints] = [s, M]),
          (this.dst[this.npoints] = [t, e]),
          this.npoints++,
          this.update();
      }),
      (Warps.prototype.add_pair = function(s, M, t) {
        let e = s ? 1 : 0,
          w = this.warps[e].warp([[M, t]])[0],
          L = w[0],
          D = w[1];
        this.add(M, t, L, D, s);
      }),
      (Warps.prototype.delete = function(s) {
        for (let M = s; M < this.npoints - 1; M++)
          (this.src[M] = this.src[M + 1].slice()),
            (this.dst[M] = this.dst[M + 1].slice());
        this.npoints--, this.update();
      }),
      (Warps.prototype.removeAll = function() {
        for (let s = 0; s < this.npoints - 1; s++)
          (this.src[s] = [0, 0]), (this.dst[s] = [0, 0]);
        (this.npoints = 0), this.update();
      }),
      (Warps.prototype.setData = function(s, M, t) {
        for (let e = 0; e < MAX_POINTS; e++)
          e < t
            ? ((this.src[e] = s[e]), (this.dst[e] = M[e]))
            : ((this.src[e] = [0, 0]), (this.dst[e] = [0, 0]));
        (this.npoints = t), this.update();
      }),
      (Canvas.prototype.check_error = function() {
        let s = this.ctx;
        null == this.errors &&
          ((this.errors = {}),
          (this.errors[s.INVALID_ENUM] = "invalid enum"),
          (this.errors[s.INVALID_VALUE] = "invalid value"),
          (this.errors[s.INVALID_OPERATION] = "invalid operation"),
          (this.errors[s.OUT_OF_MEMORY] = "out of memory"));
        for (let M = 0; M < 10; M++) {
          let M = s.getError();
          if (0 == M) return;
          throw Error(this.errors[M]);
        }
      }),
      (Canvas.prototype.shader = function(s, M, t) {
        let e = this.ctx,
          w = e.createShader(M);
        if (
          (e.shaderSource(w, t),
          e.compileShader(w),
          !e.getShaderParameter(w, e.COMPILE_STATUS))
        )
          throw Error(s + ": " + e.getShaderInfoLog(w));
        return w;
      }),
      (Canvas.prototype.program = function(s, M, t) {
        let e = this.ctx,
          w = load_source(M),
          L = load_source(t),
          D = this.shader(s + ".vertex", e.VERTEX_SHADER, w),
          i = this.shader(s + ".fragment", e.FRAGMENT_SHADER, L),
          r = e.createProgram();
        if (
          (e.attachShader(r, D),
          e.attachShader(r, i),
          e.linkProgram(r),
          !e.getProgramParameter(r, e.LINK_STATUS))
        )
          throw new Error(e.getProgramInfoLog(r));
        return this.check_error(), r;
      }),
      (Canvas.prototype.setup_programs = function() {
        (this.warp_program = this.program("warp", "warp_vertex", "warp_fragment")),
          (this.point_program = this.program(
            "points",
            "point_vertex",
            "point_fragment"
          ));
      }),
      (Canvas.prototype.make_texture = function(s) {
        let M = this.ctx;
        return (
          (texture = M.createTexture()),
          M.pixelStorei(M.UNPACK_FLIP_Y_WEBGL, 1),
          M.bindTexture(M.TEXTURE_2D, texture),
          M.generateMipmap(M.TEXTURE_2D),
          M.texParameteri(M.TEXTURE_2D, M.TEXTURE_MAG_FILTER, M.LINEAR),
          M.texParameteri(
            M.TEXTURE_2D,
            M.TEXTURE_MIN_FILTER,
            M.LINEAR_MIPMAP_LINEAR
          ),
          M.texParameteri(M.TEXTURE_2D, M.TEXTURE_WRAP_S, M.CLAMP_TO_EDGE),
          M.texParameteri(M.TEXTURE_2D, M.TEXTURE_WRAP_T, M.CLAMP_TO_EDGE),
          this.check_error(),
          texture
        );
      }),
      (Canvas.prototype.destory = function() {
        this.ctx.deleteTexture(texture),
          this.ctx.deleteBuffer(this.position_buffer),
          this.ctx.deleteBuffer(this.texcoord_buffer),
          this.ctx.deleteBuffer(this.points_buffer),
          this.ctx.deleteBuffer(this.index_buffer);
      }),
      (Canvas.prototype.setup_buffers = function() {
        let s = this.ctx,
          M = new Float32Array([-1, -1, 1, -1, 1, 1, -1, 1]);
        (this.position_buffer = s.createBuffer()),
          s.bindBuffer(s.ARRAY_BUFFER, this.position_buffer),
          s.bufferData(s.ARRAY_BUFFER, M, s.STATIC_DRAW);
        let t = new Float32Array([0, 0, 1, 0, 1, 1, 0, 1]);
        (this.texcoord_buffer = s.createBuffer()),
          s.bindBuffer(s.ARRAY_BUFFER, this.texcoord_buffer),
          s.bufferData(s.ARRAY_BUFFER, t, s.STATIC_DRAW),
          (this.points_buffer = s.createBuffer()),
          s.bindBuffer(s.ARRAY_BUFFER, this.points_buffer),
          s.bufferData(s.ARRAY_BUFFER, 2 * MAX_POINTS * 4, s.STATIC_DRAW),
          s.bindBuffer(s.ARRAY_BUFFER, null),
          (this.indices = new Uint16Array([0, 1, 2, 2, 3, 0])),
          (this.num_indices = this.indices.length),
          (this.index_buffer = s.createBuffer()),
          s.bindBuffer(s.ELEMENT_ARRAY_BUFFER, this.index_buffer),
          s.bufferData(s.ELEMENT_ARRAY_BUFFER, this.indices, s.STATIC_DRAW),
          s.bindBuffer(s.ELEMENT_ARRAY_BUFFER, null),
          this.check_error();
      }),
      (Canvas.prototype.set_uniform = function(s, M, t, e, w) {
        let L = this.ctx,
          D = L.getUniformLocation(s, M);
        if (0 == e) t.call(L, D, w);
        else {
          if (1 != e) throw new Error("invalid type");
          t.call(L, D, new Float32Array(w));
        }
      }),
      (Canvas.prototype.draw = function() {
        let s = this.ctx;
        if (
          (s.clearColor(0.5, 0.5, 1, 1),
          s.clear(s.COLOR_BUFFER_BIT),
          this.warp.npoints() >= 4)
        ) {
          s.useProgram(this.warp_program),
            this.set_uniform(
              this.warp_program,
              "u_color3",
              s.uniform1i,
              0,
              colors.tl.replace("#", "0x")
            ),
            this.set_uniform(
              this.warp_program,
              "u_color4",
              s.uniform1i,
              0,
              colors.tr.replace("#", "0x")
            ),
            this.set_uniform(
              this.warp_program,
              "u_color2",
              s.uniform1i,
              0,
              colors.br.replace("#", "0x")
            ),
            this.set_uniform(
              this.warp_program,
              "u_color1",
              s.uniform1i,
              0,
              colors.bl.replace("#", "0x")
            ),
            this.set_uniform(this.warp_program, "tex", s.uniform1i, 0, 0),
            this.set_uniform(
              this.warp_program,
              "warp",
              s.uniform1i,
              0,
              this.warp.which
            ),
            this.set_uniform(
              this.warp_program,
              "npoints",
              s.uniform1i,
              0,
              this.warp.npoints()
            ),
            this.set_uniform(
              this.warp_program,
              "points",
              s.uniform2fv,
              1,
              flatten(this.warp.src, 1)
            ),
            this.set_uniform(
              this.warp_program,
              "s2",
              s.uniform1fv,
              1,
              this.warp.s2
            ),
            this.set_uniform(
              this.warp_program,
              "w",
              s.uniform2fv,
              1,
              flatten(this.warp.w, 1)
            ),
            s.activeTexture(s.TEXTURE0);
          let M = s.getAttribLocation(this.warp_program, "a_Position"),
            t = s.getAttribLocation(this.warp_program, "a_TexCoord");
          s.enableVertexAttribArray(M),
            s.bindBuffer(s.ARRAY_BUFFER, this.position_buffer),
            s.vertexAttribPointer(M, 2, s.FLOAT, !1, 0, 0),
            s.enableVertexAttribArray(t),
            s.bindBuffer(s.ARRAY_BUFFER, this.texcoord_buffer),
            s.vertexAttribPointer(t, 2, s.FLOAT, !1, 0, 0),
            s.bindBuffer(s.ARRAY_BUFFER, null),
            s.bindBuffer(s.ELEMENT_ARRAY_BUFFER, this.index_buffer),
            s.drawElements(s.TRIANGLES, this.num_indices, s.UNSIGNED_SHORT, 0),
            s.bindBuffer(s.ELEMENT_ARRAY_BUFFER, null),
            s.disableVertexAttribArray(M),
            s.disableVertexAttribArray(t),
            s.useProgram(null);
        }
        if (this.warp.npoints() > 0 && !this.isClone) {
          s.useProgram(this.point_program),
            this.set_uniform(
              this.point_program,
              "radius",
              s.uniform1f,
              0,
              this.radius
            ),
            this.set_uniform(this.point_program, "color", s.uniform3fv, 0, [
              0,
              0,
              0
            ]);
          let M = s.getAttribLocation(this.point_program, "a_Position"),
            t = this.warp.get_src();
          s.enableVertexAttribArray(M),
            s.bindBuffer(s.ARRAY_BUFFER, this.points_buffer),
            s.bufferSubData(s.ARRAY_BUFFER, 0, new Float32Array(flatten(t, 1))),
            s.vertexAttribPointer(M, 2, s.FLOAT, !1, 0, 0),
            s.drawArrays(s.POINTS, 0, t.length),
            s.bindBuffer(s.ARRAY_BUFFER, null),
            s.disableVertexAttribArray(M),
            s.useProgram(null);
        }
        s.flush(), this.check_error();
      }),
      (Canvas.prototype.find_point = function(s, M, t, e) {
        let w = this.warp.get_src(),
          L = this.radius * this.radius;
        for (let D = 0; D < w.length; D++) {
          let i = (w[D][0] - s) / t,
            r = (w[D][1] - M) / e;
          if (i * i + r * r <= L) return D;
        }
        return null;
      }),
      (Canvas.prototype.mouse_down = function(s) {
        if (0 != s.button) return;
        let M = this.canvas.getBoundingClientRect();
        const t = {
          s: warps.src.map(s => [parseFloat(s[0]), parseFloat(s[1])]),
          d: warps.dst.map(s => [parseFloat(s[0]), parseFloat(s[1])]),
          p: warps.npoints
        };
        previousData.unshift(t),
          previousData.length > maxUndo && previousData.pop();
        let e = 2 / (M.right - M.left),
          w = 2 / (M.bottom - M.top),
          L = (s.clientX - M.left) * e - 1,
          D = (M.bottom - s.clientY) * w - 1,
          i = this.find_point(L, D, e, w);
        if (null == i)
          11 === warps.npoints
            ? alert(
                "You can not have more than 11 points. Please hold shift + left click to remove a point."
              )
            : warps.add_pair(this.warp.which, L, D);
        else if (s.shiftKey)
          4 === warps.npoints
            ? alert("You can not have less than 4 points.")
            : warps.delete(i);
        else {
          let s = this.warp.src[i];
          this.drag = [i, L, D, s[0], s[1]];
        }
        redraw();
      }),
      (Canvas.prototype.mouse_up = function(s) {
        updateUrl(),
          0 == s.button &&
            null != this.drag &&
            ((this.drag = null), warps.update(), redraw());
      });
    let previousData = [];
    const maxUndo = 20;
    let redoData = [];
    const acc = 3;
    function updateUrl(s) {
      const M = s || {
          s: warps.src
            .filter(s => 0 !== s[0] || 0 !== s[1])
            .map(s => [
              parseFloat(s[0].toFixed(acc)),
              parseFloat(s[1].toFixed(acc))
            ]),
          d: warps.dst
            .filter(s => 0 !== s[0] || 0 !== s[1])
            .map(s => [
              parseFloat(s[0].toFixed(acc)),
              parseFloat(s[1].toFixed(acc))
            ]),
          p: warps.npoints
        },
        t = btoa(JSON.stringify(M)),
        e = new URLSearchParams(window.location.search);
      e.set("w", t);
      const w = btoa(JSON.stringify(colors));
      e.set("c", w),
        window.history.replaceState(
          {},
          (location.hostname, "/"),
          "?" + e.toString()
        );
    }
    function keypressFunction(s) {
      var M = window.event ? event : s;
      if (90 == M.keyCode && M.metaKey && M.shiftKey) {
        if (redoData.length > 0) {
          const s = {
              s: warps.src.map(s => [
                parseFloat(s[0].toFixed(acc)),
                parseFloat(s[1].toFixed(acc))
              ]),
              d: warps.dst.map(s => [
                parseFloat(s[0].toFixed(acc)),
                parseFloat(s[1].toFixed(acc))
              ]),
              p: warps.npoints
            },
            M = redoData.shift();
          previousData.unshift(s),
            warps.removeAll(),
            warps.setData(M.s, M.d, M.p),
            updateUrl(M),
            redraw();
        }
      } else if (
        90 == M.keyCode &&
        M.metaKey &&
        !M.shiftKey &&
        previousData.length > 0
      ) {
        const s = previousData.shift(),
          M = {
            s: warps.src.map(s => [
              parseFloat(s[0].toFixed(acc)),
              parseFloat(s[1].toFixed(acc))
            ]),
            d: warps.dst.map(s => [
              parseFloat(s[0].toFixed(acc)),
              parseFloat(s[1].toFixed(acc))
            ]),
            p: warps.npoints
          };
        redoData.unshift(M),
          warps.removeAll(),
          warps.setData(s.s, s.d, s.p),
          updateUrl(s),
          redraw();
      }
    }
    document.addEventListener("keydown", keypressFunction),
      (Canvas.prototype.mouse_move = function(s) {
        if (0 != s.button) return;
        if (null == this.drag) return;
        let M = this.canvas.getBoundingClientRect(),
          t = M.right - M.left,
          e = M.bottom - M.top,
          w = ((s.clientX - M.left) / t) * 2 - 1,
          L = ((M.bottom - s.clientY) / e) * 2 - 1,
          D = this.drag[0],
          i = this.drag[1],
          r = this.drag[2],
          N = this.drag[3] + w - i,
          d = this.drag[4] + L - r;
        (this.warp.src[D] = [N, d]), warps.update(), redraw();
      }),
      (Canvas.prototype.setup = function() {
        this.setup_programs(),
          this.setup_buffers(),
          (this.canvas.onmousedown = this.mouse_down.bind(this)),
          (this.canvas.onmouseup = this.mouse_up.bind(this)),
          (this.canvas.onmousemove = this.mouse_move.bind(this));
      });
    let needsDraw = !1;
    function redraw() {
      needsDraw = !0;
    }
    function loop(s) {
      needsDraw && (src_c.draw(), dst_c.draw(), clone.draw(), (needsDraw = !1)),
        requestAnimationFrame(loop);
    }
    function adjust() {
      const s = document.querySelector(".body"),
        M = document.getElementById("canvas1"),
        t = document.getElementById("canvas2"),
        e =
          (M.getBoundingClientRect(),
          t.getBoundingClientRect(),
          s.getBoundingClientRect()),
        w = Math.min(e.height, e.width / 2 - 16);
      switch (aspectRatio) {
        case "1":
          (M.width = w), (M.height = w / 2), (t.width = w), (t.height = w / 2);
          break;
        case "2":
          (M.width = w / 2), (M.height = w), (t.width = w / 2), (t.height = w);
          break;
        case "3":
          (M.width = w),
            (M.height = w / (16 / 9)),
            (t.width = w),
            (t.height = w / (16 / 9));
          break;
        default:
          (M.width = w), (M.height = w), (t.width = w), (t.height = w);
      }
    }
    let tut = 0;
    function nextTut() {
      0 === tut
        ? ((document.querySelector(".t1").style.opacity = 0),
          (document.querySelector(".t2").style.opacity = 1),
          (document.querySelector("#tut2").style = "z-index: 10"),
          (document.querySelector("#tut1").style = "z-index: 0"))
        : 1 === tut &&
          (document.querySelector(".tutorial").classList.remove("visible"),
          localStorage.setItem("user", !0)),
        (tut += 1);
    }
    const user = localStorage.getItem("user");
    let clone;
    window.addEventListener("resize", adjust);
    const isSafari =
      navigator.userAgent.search("Safari") >= 0 &&
      navigator.userAgent.search("Chrome") < 0;
    function startTut() {
      document.querySelector("#welcome").classList.remove("visible");
      const s = document.querySelector(".tutorial"),
        M = document.querySelector("#tut1");
      document.querySelector("#tut2");
      s.classList.add("visible"), (M.style = "z-index: 1;");
    }
    let aspectRatio = localStorage.getItem("aspect-ratio") || 0;
    function init() {
      (document.querySelector("#aspect-ratio").options[aspectRatio].selected =
        "selected"),
        document.querySelector("#aspect-ratio").addEventListener("change", s => {
          localStorage.setItem("aspect-ratio", s.target.value),
            src_c.destory(),
            dst_c.destory(),
            location.reload(),
            init();
        }),
        /iPhone|iPad|iPod|Android/i.test(navigator.userAgent) &&
          document.querySelector(".mobile").classList.add("visible"),
        isSafari &&
          ((document.getElementById("info-dialog").style = "display: none"),
          document.querySelector(".showcase").classList.add("safari")),
        dialogPolyfill.registerDialog(document.getElementById("info-dialog"));
      const s = document.querySelector(".export-btn");
      s.addEventListener("click", () => {
        (s.href = document.getElementById("canvas3").toDataURL()),
          (s.download = "mesh-gradient.png");
      });
      const M = document.querySelector(".gallery__wrapper");
      g.forEach(s => {
        const t = new Image(),
          e = document.createElement("a");
        (e.href = s.hash),
          (t.src = "gallery/" + s.img),
          e.appendChild(t),
          M.appendChild(e);
      }),
        adjust(),
        user || document.querySelector("#welcome").classList.add("visible");
      const t = new URLSearchParams(window.location.search),
        e = t.get("w") ? JSON.parse(window.atob(t.get("w"))) : {};
      if (t.get("c"))
        try {
          const s = JSON.parse(window.atob(t.get("c")));
          colors = s;
        } catch (s) {
          console.log("err", s);
        }
      updateColors(),
        (warps = new Warps(
          e.s ? e.s.slice(0, e.p) : [],
          e.d ? e.d.slice(0, e.p) : [],
          e.p
        )),
        (src_c = new Canvas(
          warps.warps[0],
          document.getElementById("canvas1"),
          "canvas1"
        )),
        (dst_c = new Canvas(
          warps.warps[1],
          document.getElementById("canvas2"),
          "canvas2"
        )),
        (clone = new Canvas(
          warps.warps[1],
          document.getElementById("canvas3"),
          "canvas3",
          !0
        ));
      t.get("w") ||
        (() => {
          let s = [
            [-0.85, -0.9],
            [-0.95, 0.9],
            [0.85, -0.9],
            [0.95, 0.9]
          ];
          for (let M = 0; M < s.length; M++) {
            let t = s[M][0],
              e = s[M][1];
            warps.add_pair(0, t, e);
          }
        })(),
        warps.update(),
        redraw(),
        loop();
    }
    function changeColor(s) {
      (colors[s.target.getAttribute("data-gradient")] = s.target.value),
        updateUrl(),
        redraw();
    }
    function updateColors() {
      const s = document.querySelector(".btn-group");
      (s.innerHTML = ""),
        Object.keys(colors).forEach(M => {
          const t = colors[M],
            e = document.createElement("INPUT"),
            w = document.createElement("div");
          (e.value = t),
            (e.type = "color"),
            e.addEventListener("change", changeColor),
            e.setAttribute("data-gradient", M),
            w.setAttribute("aria-label", t.toUpperCase()),
            w.setAttribute("data-balloon-pos", "up"),
            w.appendChild(e),
            s.appendChild(w);
        });
    }
    let infoToggled = !1;
    function cl(s) {
      const M = document.getElementById("info-dialog");
      var t = M.getBoundingClientRect();
      (t.top <= s.clientY &&
        s.clientY <= t.top + t.height &&
        t.left <= s.clientX &&
        s.clientX <= t.left + t.width) ||
        M.close();
    }
    function toggleInfo() {
      const s = document.getElementById("info-dialog");
      (infoToggled = !infoToggled)
        ? (s.showModal(),
          s.addEventListener("click", cl),
          isSafari &&
            (s.style =
              "display: block;position: absolute; left: 50%;transform: translateX(-50%)"))
        : (s.removeEventListener("click", cl),
          isSafari && (s.style = "display: none"),
          s.close());
    }
    function debounce(s, M = 100) {
      let t;
      return function(...e) {
        clearTimeout(t),
          (t = setTimeout(() => {
            s.apply(this, e);
          }, M));
      };
    }
    function togglePreview() {
      document.getElementById("canvas1").classList.add("hidden"),
        document.getElementById("draggable").classList.add("hidden");
    }
    function toggleEdit() {
      document.getElementById("canvas1").classList.remove("hidden"),
        document.getElementById("draggable").classList.remove("hidden");
    }
    window.addEventListener(
      "resize",
      debounce(() => location.reload(), 300)
    );
    let gallery = !0;
    function toggleGallery() {
      gallery
        ? (document
            .querySelector("#submit-mesh")
            .setAttribute(
              "href",
              "mailto:burak@gradientmesh.com?subject=Check out my gradient! 🔥&body=Feature my gradient please! \n \n" +
                encodeURIComponent(document.URL)
            ),
          document.querySelector(".gallery").classList.add("open"))
        : document.querySelector(".gallery").classList.remove("open"),
        (gallery = !gallery);
    }


}

